source 'https://rubygems.org'
require 'rubygems'
# place all development, system_test, etc dependencies here

def location_for(place, fake_version = nil)
  if place =~ /^(git:[^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

# unit tests: --without system_tests development
gem 'rake',       *location_for(ENV['RAKE_VERSION'])
gem "rototiller", *location_for(ENV['TILLER_VERSION'] || '~> 0.1.0')
gem 'rspec'                  ,'~> 3.4.0'

group :system_tests do
  beaker_version     = '~> 3.0'
  nokogiri_version   = '~> 1' # any
  public_suffix_version = '~> 1' # any
  activesupport_version = '~> 1' # any
  # restrict gems to enable ruby versions
  #
  #   nokogiri comes along for the ride but needs some restriction too
  if Gem::Version.new(RUBY_VERSION).between?(Gem::Version.new('2.1.6'),Gem::Version.new('2.2.4'))
    beaker_version   = '<  3.9.0'
    nokogiri_version = '<  1.7.0'
  elsif Gem::Version.new(RUBY_VERSION).between?(Gem::Version.new('2.0.0'),Gem::Version.new('2.1.5'))
    beaker_version   = '<  3.1.0'
    nokogiri_version = '<  1.7.0'
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    beaker_version   = '~> 2.0'
    nokogiri_version = '<  1.7.0'
    public_suffix_version = '<  1.5.0'
    activesupport_version = '<  5.0.0'
  end
  gem 'beaker'               ,"#{beaker_version}"
  gem 'beaker-hostgenerator'
  gem 'nokogiri'             ,"#{nokogiri_version}"
  gem 'public_suffix'        ,"#{public_suffix_version}"
  gem 'activesupport'        ,"#{activesupport_version}"
end

group :development do
  gem 'simplecov'
  #Documentation dependencies
  gem 'yard'                 ,'~> 0'
  gem 'markdown'             ,'~> 0'
end

local_gemfile = "#{__FILE__}.local"
if File.exists? local_gemfile
  eval(File.read(local_gemfile), binding)
end

user_gemfile = File.join(Dir.home,'.Gemfile')
if File.exists? user_gemfile
  eval(File.read(user_gemfile), binding)
end
