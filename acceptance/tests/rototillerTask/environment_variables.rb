require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97797: ensure environment variable operation in RototillerTasks' do
  extend Beaker::Hosts
  extend RakefileTools

  def create_rakefile_task_segment(envs)
    segment = ''
    envs.each do |env|
      sut.add_env_var(env[:name], "present value") if env[:exists]
      segment += "t.add_env('#{env[:name]}'"
      segment += ", '#{env[:default]}'" if env[:default]
      segment += ", '#{env[:message]}'"
      segment += '); '
      segment += "puts ENV['#{env[:name]}']; "
    end
    return segment
  end

  env_vars = [
    {:name => 'NO_DEFAULT-EXISTS',    :message => 'no default, previously exists',
     :default => nil,                 :exists => true},
    {:name => 'DEFAULT-EXISTS',       :message => 'default, previously exists',
     :default => 'present default value',   :exists => true},
    {:name => 'NO_DEFAULT-NO_EXISTS', :message => 'no default, does not previously exist',
     :default => nil,                 :exists => false},
    {:name => 'DEFAULT-NO_EXISTS',    :message => 'default, does notpreviously exist',
     :default => 'notpresent default value', :exists => false},
  ]

  @test_command = 'printenv'
  @task_name    = 'env_var_testing_task'
  rakefile_contents = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
  #{create_rakefile_task_segment(env_vars)}
  t.command = "#{@test_command}"
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  step 'Execute task defined in rake task' do
    on(sut, "rake #{@task_name}", :accept_all_exit_codes => true) do |result|
      # exit code & no error in output
      assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
      assert_no_match(/error/i, result.output, 'An unexpected error was observed')

      env_vars.each do |env|
        # validate notification to user of ENV value
        #assert_match(/, result.stdout, 'The expected messaging was not observed')

        # Use test command output to validate value of ENV used by task
        #assert_match(command_regex, result.stdout, 'The observed value of the ENV was different than expected')
      end
    end
  end

end
