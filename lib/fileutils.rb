require 'awesome_print'

def locate_index_data(rootpath, indexname)
  index_config = File.join(rootpath, "indexinfo-#{indexname}.json")
  raise RuntimeError, "Could not locate file #{index_config}" unless File.exists?(index_config)

  index_data = Dir.glob(File.join(rootpath,"indexdata-#{indexname}-*.json"))
  return {
    :config=>index_config,
    :data_files=>index_data
  }
end #def locate_index_data

def fix_entry(entry, strip_fields)
  entry.delete('_score')
  entry.delete('sort')
  entry_source = entry.delete('_source')
  strip_fields.each {|field_to_remove|
    #$logger.debug("Removing field #{field_to_remove}")
    entry_source.delete(field_to_remove)
  }
  entry_source = entry_source.select {|fieldname,value|
    if(fieldname=="") then
      $logger.warn("Field with data #{value} has an empty name, removing it")
      false
    else
      true
    end
  }
  if entry.has_key?('_id')
      entry['_id'] = entry['_id'][0..511] if entry['_id'].length>512
  end
  [entry, entry_source]
end

def upload_data_file(address, indexname, datafile, strip_fields)
  $logger.info("Reading in #{datafile}")
  datacontent = File.open datafile, "r" do |f|
    JSON.parse(f.read())
  end

  bulkdata = datacontent['hits']['hits'].reduce("") { |acc, entry|
    entry, entry_source = fix_entry(entry, strip_fields)
    if entry_source.size > 1000
      $logger.warn("This record has #{entry_source.size} fields, but ES supports a maximum of 1000. Use the strip-fields option to remove some fields in order to make this indexable")
    else
      acc + JSON.generate({"index"=>entry}) + "\n" + JSON.generate(entry_source) + "\n"
    end
  }

  if bulkdata.length==0
    $logger.warn("Nothing to upload!")
    return
  end

  $logger.info("Uploading via bulk api")
  uri = URI("#{address}/_bulk")
  $logger.debug("Connecting to #{uri}...")
  Net::HTTP.start(uri.hostname, uri.port) do |http|
    rq = Net::HTTP::Post.new uri
    rq['Content-Type'] = 'application/json'
    rq.body = bulkdata+"\n"

    response = http.request rq
    reply = JSON.parse(response.body)
    #ap reply
    unless response.code=='200'
      print bulkdata
      ap reply
      raise RuntimeError, "Could not upload data, server returned #{response.code} error"
    end #unless response.code==200

    if reply["errors"] then
      print bulkdata
      ap reply
      raise RuntimeError, "Could not upload data, server returned some values failed"
    end
  end #Net::HTTP.start
end #def upload_data_file
