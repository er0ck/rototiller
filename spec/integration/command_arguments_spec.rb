require_relative 'integration_helper'

describe RototillerTestTask do
  it 'can add one argument' do
    # TODO: create helper to create randomized task names
    # TODO: abstract this Proc.new crap
    task_name = 'abstract_me_to_randomness'
    block = Proc.new { |t| t.add_command({:name => 'echo', :add_argument => {:name => "#{task_name}"}}) }
    expect{ described_class.new(task_name, &block) }.to output(task_name).to_stdout
  end
end
