require 'rspec/core/rake_task'

task :environment do
  # noop
end

desc 'Run the specs'
RSpec::Core::RakeTask.new do |r|
  r.verbose = false
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r duranged"
end

task :build do
  puts `gem build duranged.gemspec`
end

task :push do
  require 'duranged/version'
  puts `gem push duranged-#{Duranged::VERSION}.gem`
end

task release: [:build, :push] do
  puts `rm -f duranged*.gem`
end

task :default => :spec
