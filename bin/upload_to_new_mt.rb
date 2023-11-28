#!/usr/bin/env ruby

require 'optimist'
require 'awesome_print'
require 'net/http'
require 'json'
require 'logger'
require 'thread'
require 'etc'
require 'indexutils'
require 'fileutils'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

opts = Optimist::options do
  opt :cluster, "Connect to Elasticsearch at this uri", :type=>:string,:default=>"http://localhost:9200"
  opt :index, "Create this index", :type=>:string
  opt :allow_overwrite, "Allow the deletion of an existing index", :type=>:boolean, :default=>false
  opt :input, "Read json files from this directory", :type=>:string,:default=>Dir.pwd
  opt :strip_fields, "Comma separated list of fields to remove before uploading", :type=>:string,:default=>""
  opt :threads, "Number of processing threads to run", :type=>:integer, :default=>Etc.nprocessors*2
end


#START MAIN
#Establish connection
$logger.info("Starting up")
check_cluster(opts.cluster)

#Get index setup
if opts[:index].nil? then
  $logger.error("You must specify an index name on the commandline with --index")
  exit(2)
end

$logger.info("Locating files to upload")
filesinfo = locate_index_data(opts.input, opts[:index])
$logger.info("Got #{filesinfo[:data_files].length} data files to restore")

$logger.info("Checking index #{opts[:index]}")
indexinfo = check_index_write(opts.cluster, opts[:index], opts[:allow_overwrite])

$logger.info("Creating index #{opts[:index]}")
create_index(opts.cluster, opts[:index], filesinfo[:config])

strip_fields = opts.strip_fields.split(/\s*,\s*/)

$logger.info("Uploading data files")
$global_queue = Queue.new

thread_list = []
opts.threads.times do |i|
  thread_list << Thread.new {
    $logger.info("Started thread #{i}")
    while true do
      datafile = $global_queue.pop
      if datafile==nil
        logger.info("Received nil value, terminating thread")
        return
      end
      upload_data_file(opts.cluster,opts[:index], datafile, strip_fields)
    end
  }
end

p=1
filesinfo[:data_files].each { |datafile|
  $logger.info("#{p}/#{filesinfo[:data_files].length}: Queueing #{datafile}")
  $global_queue << datafile
  #upload_data_file(opts.cluster,opts[:index], datafile, strip_fields)
  p+=1
}

thread_list.each { |t| $global_queue << nil }
$logger.info("Waiting for threads to finish")
thread_list.each { |t| t.join }
