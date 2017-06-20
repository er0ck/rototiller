require 'rototiller'
require 'rototiller/task/collections/env_collection'
require 'rototiller/task/collections/command_collection'

# tools for running a rototiller_task on localhost
# WARNING: this WILL run tasks ON your system if you tell it to.
class RototillerTestTask < Rototiller::Task::RototillerTask

  def initialize(*args, &task_block)
    @name          = args.shift
    @fail_on_error = true
    @commands      = Rototiller::Task::CommandCollection.new

    # rake's in-task implied method is true when using --verbose
    @verbose       = verbose == true
    @env_vars      = Rototiller::Task::EnvCollection.new
    task(@name, *args) do |_, task_args|
      task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
      puts @name
      puts @commands
      run_task
    end
  end

end
