require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97830: describe and list RototillerTasks' do
  extend Beaker::Hosts
  extend RakefileTools

  @task_body_string = 'Lorem ipsum dolor sit amet'
  def create_rakefile_task_segment(options)
    description = "desc '#{options[:init_method]} #{options[:description]}'" if options[:description]
    segment = <<-EOS
#{description}
Rototiller::Task::RototillerTask.#{options[:init_method]} :#{options[:init_method]}#{options[:description]} do |t|
  puts '#{options[:init_method]}#{options[:description]} #{@task_body_string} '
end
EOS
  end

  tasks = [
    {:init_method => 'define_task', :description =>  nil },
    {:init_method => 'define_task', :description => 'yep'},
    {:init_method => 'new', :description =>  nil },
    {:init_method => 'new', :description => 'yep'},
  ]

  rakefile_contents = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

  EOS

  tasks.each do |task|
    rakefile_contents = rakefile_contents + create_rakefile_task_segment(task)
  end
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  tasks.each do |task|
    step "Use the -T flag to test task '#{task[:task_name]}' description"
    on(sut, "rake -T --rakefile #{rakefile_path}", :accept_all_exit_codes => true) do |result|
      assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
      assert_no_match(/error/i, result.output, 'An unexpected error was observed')
      if task[:description]
        assert_match(/#{task[:init_method]}#{task[:description]}/, result.stdout, "The correct description '#{task[:init_method]}#{task[:description]}' was not observed")
      else
        assert_match(/#{task[:init_method]}\s+ # RototillerTask/, result.stdout, "The correct description '#{task[:init_method]}' was not observed")
      end
    end

    step "Execute task defined in rake task '#{task[:init_method]}#{task[:description]}'"
    on(sut, "rake #{task[:init_method]}#{task[:description]}", :accept_all_exit_codes => true) do |result|
      assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
      assert_no_match(/error/i, result.output, 'An unexpected error was observed')
      assert_match(/#{options[:init_method]}#{options[:description]} #{@task_body_string}/, result.stdout, "The expected output from the task '#{options[:init_method]}#{options[:description]}' was not observed")
    end
  end

end
