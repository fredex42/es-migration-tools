require 'IndexInfo'
require 'awesome_print'

RSpec.describe IndexInfo, "#get" do
  it "returns the current state of IndexInfo object" do
    i = IndexInfo.new(nil)
    expect(i.get()).to eq Hash({"indexname"=>{
      "aliases"=>{},
      "mappings"=>{},
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})
  end
end

RSpec.describe IndexInfo, "#aliases" do
  it "returns the aliases part of the current data" do
    test_data = Hash({"idx"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{},
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})
    i = IndexInfo.new(test_data)

    expect(i.aliases).to eq Hash({"somekey"=>"somevalue"})
  end
end

RSpec.describe IndexInfo, "#set_aliases" do
  it "sets the aliases part of the current data" do
    test_data = Hash({"idx"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{},
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})
    i = IndexInfo.new(test_data)
    i.set_aliases(Hash({"otherkey"=>"othervalue"}))
    expect(i.aliases).to eq Hash({"otherkey"=>"othervalue"})
  end
end

RSpec.describe IndexInfo, "#settings" do
  it "returns the settings part of the current data" do
    test_data = Hash({"idx"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{},
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})
    i = IndexInfo.new(test_data)

    expect(i.settings).to eq Hash({"number_of_shards"=>"3","number_of_replicas"=>"1"})
  end
end

RSpec.describe IndexInfo, "#set_settings" do
  it "overwrites the settings part of the current data" do
    test_data = Hash({"idx"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{},
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})
    i = IndexInfo.new(test_data)
    i.set_settings(Hash({"number_of_shards"=>"1","number_of_replicas"=>"4"}))
    expect(i.settings).to eq Hash({"number_of_shards"=>"1","number_of_replicas"=>"4"})
  end
end

RSpec.describe IndexInfo, "#mapping_names" do
  it "should yield out the names of each mapping in the current data" do
    test_data = Hash({"indexname"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{
        "mapping1"=>{
          "properties"=>{
            "field1"=>{
              "type"=>"string",
              "index"=>"not_analyzed"
            },
            "field2"=>{
              "type"=>"integer"
            },
            "field3"=>{
              "type"=>"string"
            }
          }
        },
        "mapping2"=>{
          "properties"=>{}
        }
      },
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})
    i = IndexInfo.new(test_data)

    result = []
    i.mapping_names {|n| result << n}
    expect(result).to eq ["mapping1","mapping2"]
  end
end

RSpec.describe IndexInfo, "#fields_for" do
  it "should yield out tuples of (fieldname, fielddata) for each field of the given mapping" do
    test_data = Hash({"idx"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{
        "mapping1"=>{
          "properties"=>{
            "field1"=>{
              "type"=>"string",
              "index"=>"not_analyzed"
            },
            "field2"=>{
              "type"=>"integer"
            },
            "field3"=>{
              "type"=>"string"
            }
          }
        },
        "mapping2"=>{
          "properties"=>{}
        }
      },
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})

    i = IndexInfo.new(test_data)
    result = []
    i.fields_for("mapping1") { |t|


      result << {t[0]=>t[1]}
    }
    expect(result).to eq [
      {"field1"=>{
        "type"=>"string",
        "index"=>"not_analyzed"
      }},
      {"field2"=>{
        "type"=>"integer"
      }},
      {"field3"=>{
        "type"=>"string"
      }}
    ]
  end
end

RSpec.describe IndexInfo, "#update_field_types" do
  it "should return a new object with updated field types" do
    test_data = Hash({"idx"=>{
      "aliases"=>{"somekey"=>"somevalue"},
      "mappings"=>{
        "mapping1"=>{
          "properties"=>{
            "field1"=>{
              "type"=>"string",
              "index"=>"not_analyzed"
            },
            "field2"=>{
              "type"=>"integer"
            },
            "field3"=>{
              "type"=>"string"
            }
          }
        },
        "mapping2"=>{
          "properties"=>{}
        }
      },
      "settings"=>{
        "number_of_shards"=>"3",
        "number_of_replicas"=>"1"
      }
    }})

    i = IndexInfo.new(test_data)
    result = []
    updated = i.update_field_types
    updated.fields_for("mapping1") { |t|
      result << {t[0]=>t[1]}
    }

    expect(result).to eq [
      {"field1"=>{"type"=>"keyword"}},
      {"field2"=>{"type"=>"integer"}},
      {"field3"=>{"type"=>"text"}}
    ]

    expect(updated.aliases).to eq Hash({"somekey"=>"somevalue"})
    expect(updated.settings).to eq Hash({"number_of_shards"=>"3","number_of_replicas"=>"1"})
  end
end
