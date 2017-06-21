require 'rototiller'

# tools for running a rototiller_task on localhost
# WARNING: this WILL run tasks ON your system if you tell it to.
class RototillerTestTask

  def initialize(*args, &block)
    task = Rototiller::Task::RototillerTask.define_task(*args, &block)
    task.send('run_task')
  end

end
