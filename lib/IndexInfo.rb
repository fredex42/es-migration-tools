require 'logger'
require 'facets/tuple'

class IndexInfo
  def initialize(oldinfo)
    if(not oldinfo.nil?)
      @indexnames = oldinfo.map {|idxname,idxdata| idxname}

      @current_info = oldinfo[@indexnames[0]]
    else
      @indexnames = ["indexname"]
      @current_info = Hash({
        "aliases"=>{},
        "mappings"=>{},
        "settings"=>{
          "number_of_shards"=>"3",
          "number_of_replicas"=>"1"
        }
      })
    end
  end

  def get
    Hash({@indexnames[0]=>@current_info})
  end

  def set_index_name(indexName)
    @indexnames = [indexName]
  end
  def mapping_names(&block)
    @current_info["mappings"].each { |mappingname,mappinginfo| yield mappingname }
  end

  def add_mapping(mappingName)
    @current_info["mappings"][mappingName] = {"properties"=>{}}
  end

  def fields_for(mappingName)
    raise ValueError, "No mapping #{mappingName} present on this index data" if(not @current_info["mappings"].key?(mappingName))
    @current_info["mappings"][mappingName]["properties"] = {} if(not @current_info["mappings"][mappingName].key?("properties"))

    @current_info["mappings"][mappingName]["properties"].each {|fieldname,fielddata| yield Tuple[fieldname, fielddata]}
  end

  def field_count(mappingName)
    @current_info["mappings"][mappingName]["properties"].length
  end

  def set_field(mappingName, fieldName, fieldData)
    @current_info["mappings"][mappingName]["properties"][fieldName] = fieldData
  end

  def set_aliases(dataHash)
    @current_info["aliases"] = dataHash
  end

  def aliases
    @current_info["aliases"]
  end

  def set_settings(dataHash)
    @current_info["settings"] = dataHash
  end

  def settings
    @current_info["settings"]
  end

  #updates v1.x field types to v 5+ field types
  def update_field_types(truncate_field_count=false)
    updated_info = IndexInfo.new(nil)
    updated_info.set_aliases(@current_info["aliases"])
    updated_info.set_settings(@current_info["settings"])
    updated_info.set_index_name(@indexnames[0])

    self.mapping_names {|mappingname|
      updated_info.add_mapping(mappingname)
      if self.field_count(mappingname)>1000
        $logger.warn("Mapping #{mappingname} has #{self.field_count(mappingname)} fields, but ElasticSearch only supports 1000. Use the --strip-fields option to remove some and retry")
        next if(!truncate_field_count) 
      end

      n=0
      self.fields_for(mappingname) {|fieldname, fielddata|
        updated_field_data = {}
        if(fielddata["type"]=="string" and fielddata["index"]=="not_analyzed") then
          updated_field_data = {"type"=>"keyword"}
        elsif (fielddata["type"]=="string") then
          updated_field_data = fielddata
          updated_field_data["type"] = "text"
        else
          updated_field_data = fielddata
        end
        updated_info.set_field(mappingname, fieldname, updated_field_data)
        n+=1
        break if(n>=1000)
      }
    }
    updated_info
  end
end #class IndexInfo
