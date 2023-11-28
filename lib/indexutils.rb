
def check_cluster(address)
  $logger.debug("Connecting to #{address}...")
  uri = URI(address)
  raw_json = Net::HTTP.get(uri)
  content = JSON.parse(raw_json)
  $logger.info("Connected to #{content['cluster_name']}, ES version #{content['version']['number']}. Status is #{content['status']}")
  raise RuntimeError, "Server is in an error state" if content.key?("status") and content['status'] != 200
end #def check_cluster

def check_index(address, indexname)
  uri = URI(File.join(address,indexname))
  $logger.debug("Connecting to #{uri}...")
  response = Net::HTTP.get_response(uri)
  content = JSON.parse(response.body)
  if response.code != '200'
    ap content
    raise RuntimeError, "Could not access index #{indexname}, server returned a #{response.code} error"
  end
  $logger.info("Got information about index #{indexname}")
  content
end

def check_index_write(address, indexname, allow_overwrite=false)
  uri = URI(File.join(address,indexname))
  $logger.debug("Connecting to #{uri}...")
  response = Net::HTTP.get_response(uri)
  content = JSON.parse(response.body)
  if response.code == '200'
    if allow_overwrite
      delete_index(address,indexname)
    else
      raise RuntimeError,  "Index #{indexname} already exists, not continuing as --allow_overwrite not specified.  If you specify this option then the existing index will be deleted."
    end
  elsif response.code != '404'
    ap content
    raise RuntimeError, "Could not access index #{indexname}, server returned a #{response.code} error"
  end

  $logger.info("Ready to write index #{indexname}")
end

def delete_index(address, indexname)
  uri = URI(File.join(address,indexname))
  $logger.debug("Connecting to #{uri}...")
  Net::HTTP.start(uri.hostname,uri.port) do |http|
    rq = Net::HTTP::Delete.new uri
    response = http.request rq
    content = JSON.parse(response.body)
    if response.code != '200'
      ap content
      raise RuntimeError, "Could not delete #{indexname}, server returned #{response.code}"
    end #if response.code
  end #Net::HTTP.start
end #delete_index

def create_index(address, indexname, configfile)
  configdata = File.open configfile, "r" do |f|
    JSON.parse(f.read())
  end
  #the configdata has an extra json level containing the index name that we don't need
  if configdata.values.length > 1
    raise RuntimeError, "This configdata has more than one index?"
  end

  configroot = configdata.values[0]
  #remove incompatible values
  configroot['settings']['index'].delete('creation_date')
  configroot['settings']['index'].delete('uuid')
  configroot['settings']['index']['version'].delete('created')

  uri = URI("#{address}/#{indexname}")
  $logger.debug("Connecting to #{uri}...")
  Net::HTTP.start(uri.hostname, uri.port) do |http|
    rq = Net::HTTP::Put.new uri
    rq.body = JSON.generate(configroot)
    rq['Content-Type'] = 'application/json'

    response = http.request rq
    unless response.code=='200'
      error_info = JSON.parse(response.body)
      ap error_info
      raise RuntimeError, "Could not create index, server returned #{response.code} error"
    end #unless response.code==200
  end #Net::HTTP.start
end #def create_index
