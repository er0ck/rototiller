require 'rspec/core/rake_task'
require 'fileutils'
require 'rototiller'

task :default => :test

desc "Run spec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = ENV['SPEC_PATTERN']
end

task :test => [:check_test]

task :generate_host_config do |t, args|

  target = ENV["LAYOUT"] || ENV["TEST_TARGET"] || 'centos7-64'
  generate = "beaker-hostgenerator"
  generate += " #{target}"
  generate += " > acceptance/hosts.cfg"
  sh generate
  sh "cat acceptance/hosts.cfg"
end

default_rake_ver = '11.0'

rototiller_task :acceptance => [:generate_host_config] do |t|
  t.add_env({:name => 'LAYOUT',   :default => 'centos7-64',
             :message => 'The argument to pass to beaker-hostgenerator',
             :set_env => true})
  t.add_env({:name => 'RAKE_VER', :default => default_rake_ver,
             :message => 'The rake version to use when running unit and acceptance tests',
             :set_env => true})

  t.add_flag do |flag|
    flag.name = '--hosts'
    flag.default = 'acceptance/hosts.cfg'
    flag.message = 'The configuration file that Beaker will use'
    flag.override_env = 'BEAKER_HOSTS'
  end
  t.add_flag do |flag|
    flag.name = '--preserve-hosts'
    flag.default = 'onfail'
    flag.message = 'The beaker setting to preserve a provisioned host'
    flag.override_env = 'BEAKER_PRESERVE_HOSTS'
  end
  t.add_flag do |flag|
    flag.name = '--keyfile'
    flag.default ="#{ENV['HOME']}/.ssh/id_rsa-acceptance"
    flag.message = 'The SSH key used to access a SUT'
    flag.override_env = 'BEAKER_KEYFILE'
  end
  t.add_flag do |flag|
    flag.name = '--load-path'
    flag.default = 'acceptance/lib'
    flag.message = 'The load path Beaker will use'
    flag.override_env = "BEAKER_LOAD-PATH"
  end
  t.add_flag do |flag|
    flag.name = '--pre-suite'
    flag.default = 'acceptance/pre-suite'
    flag.message = 'THe path to a directory containing pre-suites'
    flag.override_env = "BEAKER_PRE-SUITE"
  end
  t.add_flag do |flag|
    flag.name = '--tests'
    flag.default = 'acceptance/tests'
    flag.message = 'The path to the tests you want beaker to run'
    flag.override_env = 'BEAKER_TESTS'
  end

  t.add_command({:name => 'beaker --debug --no-ntp --repo-proxy --no-validate', :override_env => 'BEAKER_EXECUTABLE'})
end

rototiller_task :check_test do |t|
  t.add_env({:name => 'SPEC_PATTERN', :default => 'spec/', :message => 'The pattern RSpec will use to find tests', :set_env => true})
  t.add_env({:name => 'RAKE_VER',     :default => default_rake_ver,  :message => 'The rake version to use when running unit tests', :set_env => true})
end

task :yard => [:'docs:gen']

namespace :docs do
  YARD_DIR = 'doc'
  desc 'Clear the generated documentation cache'
  task :clear do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    sh "rm -rf #{YARD_DIR}"
    Dir.chdir( original_dir )
  end

  desc 'Generate static documentation'
  task :gen do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    output = `yard doc`
    puts output
    if output =~ /\[warn\]|\[error\]/
      begin # prevent pointless stack on purposeful fail
        fail "Errors/Warnings during yard documentation generation"
      rescue Exception => e
        puts 'Yardoc generation failed: ' + e.message
        exit 1
      end
    end
    Dir.chdir( original_dir )
  end

  desc 'Check amount of documentation'
  task :check do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    output = `yard stats --list-undoc`
    puts output
    if output =~ /\[warn\]|\[error\]/
      begin # prevent pointless stack on purposeful fail
        fail "Errors/Warnings during yard documentation generation"
      rescue Exception => e
        puts 'Yardoc generation failed: ' + e.message
        exit 1
      end
    end
    Dir.chdir( original_dir )
  end

  desc 'Generate static class/module/method graph'
  task :class_graph => [:gen] do
    DOCS_DIR = 'docs'
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    graph_processor = 'dot'
    if exe_exists?(graph_processor)
      FileUtils.mkdir_p(DOCS_DIR)
      if system("yard graph --full | #{graph_processor} -Tpng -o #{DOCS_DIR}/rototiller_class_graph.png")
        puts "we made you a class diagram: #{DOCS_DIR}/rototiller_class_graph.png"
      end
    else
      puts 'ERROR: you don\'t have dot/graphviz; punting'
    end
    Dir.chdir( original_dir )
  end
end

# Cross-platform exe_exists?
def exe_exists?(name)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{name}#{ext}")
      return true if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return false
end
