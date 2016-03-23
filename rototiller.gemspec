# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rototiller/version'

Gem::Specification.new do |s|
  s.name          = 'rototiller'
  s.authors       = ["Puppetlabs"]
  s.email         = ["qa@puppetlabs.com"]
  s.summary       = 'Puppetlabs rake tool'
  s.description   = 'Puppetlabs tool for building rake tasks'
  s.homepage      = "https://github.com/puppetlabs/rototiller"
  s.version       = Rototiller::Version::STRING
  s.license       = 'Apache-2.0'
  s.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*']

  #Development dependencies
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'simplecov'

  #Documentation dependencies
  s.add_development_dependency 'yard'      , '~> 0'
  s.add_development_dependency 'markdown'  , '~> 0'

  # restrict version to enable ruby 1.9.3
  s.add_development_dependency 'mime-types', '~> 2.0'

  #Run time dependencies
  s.add_runtime_dependency 'rake'
end
