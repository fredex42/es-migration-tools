Gem::Specification.new do |s|
  s.name        = 'es-migration-tools'
  s.version     = '1.0.0'
  s.licenses    = ['MIT']
  s.summary     = "Scripts to help migrate data from one ElasticSearch version to another"
  s.authors     = ["Andy Gallagher"]
  s.email       = 'andy.gallagher@theguardian.com'
  s.files       = ["lib/IndexInfo.rb", "lib/indexutils.rb", "lib/fileutils.rb"]
  s.executables = ["download_from_old.rb","upload_to_new.rb","upload_to_new_mt.rb"]
  s.add_runtime_dependency 'awesome_print',  '~> 1.8', '>= 1.8.0'
  s.add_runtime_dependency 'optimist', '~> 3.0', '>= 3.0.0'
  s.add_runtime_dependency 'facets', '~> 3.1', '>= 3.1.0'
  s.homepage    = ''
  s.metadata    = {  }
end
