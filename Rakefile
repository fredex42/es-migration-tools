require 'rspec/core/rake_task'
require 'rubygems/command_manager'

RSpec::Core::RakeTask.new(:test)

task :build do
  Gem::CommandManager.instance.run(["build","es-migration-tools.gemspec"])
end
