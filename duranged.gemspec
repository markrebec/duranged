$:.push File.expand_path("../lib", __FILE__)
require "duranged/version"

Gem::Specification.new do |s|
  s.name        = "duranged"
  s.version     = Duranged::VERSION
  s.summary     = "A set of classes to facilitate working with and formatting durations, intervals, time ranges and occurrences."
  s.description = "A set of classes to facilitate working with and formatting durations, intervals, time ranges and occurrences."
  s.authors     = ["Mark Rebec"]
  s.email       = ["mark@markrebec.com"]
  s.homepage    = "http://github.com/markrebec/duranged"

  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency "activesupport"
  s.add_dependency "chronic_duration"
  s.add_dependency "canfig"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
