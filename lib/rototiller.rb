if ENV["BEAKER_COVERAGE"]
  require 'simplecov'
  SimpleCov.start
  SimpleCov.command_name "bundle"
end
require 'rototiller/rake/dsl/dsl_extention'
require 'rototiller/task/rototiller_task'
