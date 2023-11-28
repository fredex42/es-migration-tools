#!/usr/bin/env ruby

require 'optimist'
require 'awesome_print'
require 'net/http'
require 'json'
require 'logger'
require 'indexutils'
require 'IndexInfo'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

opts = Optimist::options do
  opt :cluster, "Connect to Elasticsearch at this uri", :type=>:string,:default=>"http://localhost:9200"
  opt :index, "Download this index", :type=>:string
  opt :output, "Output json files to this directory", :type=>:string,:default=>Dir.pwd
  opt :chunksize, "Get this many records per json file", :type=>:integer, :default=>1000
  opt :sortfield, "Sort by this field when retrieving", :type=>:string, :default=>"timestamp"
  opt :redownload, "Overwrite existing files rather than skip them", :type=>:boolean, :default=>false
  opt :noupdate, "Don't update string fields to the newer text/keyword syntax", :type=>:boolean, :default=>false
  opt :truncate_field_count, "If the source data has more than 1000 fields then only keep the first 1000. Using --strip-fields is preferable.", :type=>:boolean, :default=>false
end

def download_next_page(http,address,indexname, outputdir, page_number, page_size, sortfield, redownload)
  #returns TRUE if more results, otherwise FALSE
  from = page_number * page_size
  outfile = File.join(outputdir,"indexdata-#{indexname}-#{page_number}.json")

  if File.exists?(outfile) and not redownload
    $logger.info("File #{outfile} already exists, skipping download of this chunk")
    return true
  end

  uri = URI("#{address}/#{indexname}/_search?from=#{from}&size=#{page_size}")
  $logger.debug("Connecting to #{uri}...")

  while true
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'

    request.body = JSON.generate({"query":{"match_all": {}}, "sort":[{"#{sortfield}":"asc"}]})
    response = http.request request

    if response.code == '504' or response.code=='503'
      $logger.warn("Got timeout error #{response.code} from server, retrying in 10s")
      sleep(10)
    elsif response.code != '200'
      $logger.error(response.body)
      raise RuntimeError, "Could not download page data, server returned #{response.code} error"
    else
      break
    end
  end #while true

  content = JSON.parse(response.body)

  expected_pages = content['hits']['total']/page_size
  $logger.info("Writing page #{page_number} (out of expected #{expected_pages}) to #{outfile}")
  open outfile,"w" do |f|
    f.write(response.body)
  end #open outfile
  return content['hits']['hits'].length==page_size
end #def download_next_page

#START MAIN

#Establish connection
$logger.info("Starting up")
check_cluster(opts.cluster)

#Get index setup
$logger.info("Checking index #{opts[:index]}")
indexinfo_raw = check_index(opts.cluster, opts[:index])
ap indexinfo_raw
info = IndexInfo.new(indexinfo_raw)

if opts.noupdate
  updated_index_info = indexinfo_raw
else
  updated_index_info = info.update_field_types(opts[:truncate_field_count]).get
  ap updated_index_info
end

outpath = File.join(opts.output,"indexinfo-#{opts[:index]}.json")
if File.exists?(outpath) and not opts.redownload
  $logger.info("Not overwriting #{outpath}")
else
  $logger.info("Outputting to #{outpath}")
  open outpath, "w" do |f|
    f.write(JSON.generate(updated_index_info))
  end #open
end #if File.exists?

page_number=0

search_uri = URI("#{opts.cluster}/#{opts[:index]}/_search")

Net::HTTP.start(search_uri.host, search_uri.port, :use_ssl=>opts.cluster.start_with?("https")) do |http|
  more_hits=true
  while more_hits
    more_hits=download_next_page(http, opts.cluster, opts[:index], opts.output, page_number, opts.chunksize, opts.sortfield, opts.redownload)
    ap more_hits
    page_number+=1
  end #while True
end #Net::HTTP.start

$logger.info("Completed, dumped #{page_number} pages of results")
