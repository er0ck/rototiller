require 'spec_helper'

module Rototiller
  module Task

    # use each of these for the objects passed from it_behaves_like below
    #   (each of command from hash and command from block
    shared_examples "a Command object" do
      before(:each) do
        # stub out all the PRY env use, or the mocks for ENV below will break pry
        pryrc = ENV['PRYRC']
        disable_pry = ENV['DISABLE_PRY']
        home = ENV['HOME']
        ansicon = ENV['ANSICON']
        term = ENV['TERM']
        pager = ENV['PAGER']
        lines = ENV['LINES']
        allow(ENV).to receive(:[]).with('PRYRC').and_return(pryrc)
        allow(ENV).to receive(:[]).with('DISABLE_PRY').and_return(disable_pry)
        allow(ENV).to receive(:[]).with('HOME').and_return(home)
        allow(ENV).to receive(:[]).with('ANSICON').and_return(ansicon)
        allow(ENV).to receive(:[]).with('TERM').and_return(term)
        allow(ENV).to receive(:[]).with('PAGER').and_return(pager)
        allow(ENV).to receive(:[]).with('LINES').and_return(lines)

        @arg_name      = "VARNAME_#{(0...8).map { (65 + rand(26)).chr }.join}"
        @command_name  = 'echo'
        #FIXME: refactor these so we better do blocks vs hashes
        @args = {:name => @command_name, :add_argument => {:name => @arg_name}, :message => 'killer message'}
        @block = Proc.new { |b| b.name = @command_name; b.add_argument({:name => @arg_name}); b.message = 'killer message'}
      end

      describe '#name' do
        it 'can directly set name' do
          expect{ command.name = 'wah' }.not_to raise_error
          expect(command.name).to eq('wah')
        end
        it 'returns the name' do
          expect(command.name).to eq(@command_name)
        end
      end

      describe '#result' do
        it 'can not directly set result' do
          expect{ command.result = 'wah' }.to raise_error(NoMethodError)
        end
        it 'has nil results prior to run' do
          expect( command.result ).to be_nil
        end
        it 'has streams results to stdout during run' do
          #FIXME: i can't figure out how to ensure that it prints before the thread returns
        end
        it 'has results after successful run' do
          command.run
          expect( command.result.output.strip ).to eq('')
          expect( command.result.exit_code ).to eq(0)
        end
        it 'has results after failed run' do
          command.name = 'doesnotexist'
          command.run
          expect( command.result.output.strip ).to match(/doesnotexist\: command not found/)
          expect([2,127]).to include(command.result.exit_code)
        end
        context 'with a block' do
          it 'runs the block' do
            expect{ command.run { |result| puts "my exit_code: '#{result.exit_code}'" } }.to output("my exit_code: '0'\n").to_stdout
          end
        end
      end

      describe '#add_env' do
        it 'can not directly set env_vars' do
          expect{ command.env_vars << 'wah' }.to raise_error(NoMethodError)
        end
        describe 'as hash' do
          it 'does not override command name with empty env_var' do
            # set env first, or command might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return(nil)
            command.add_env({:name => 'BLAH'})
            expect(command.name).to eq(@command_name)
          end
          it 'can override command name with env_var' do
            # set env first, or command might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return('my_shiny_new_command')
            command.add_env({:name => 'BLAH'})
            expect(command.name).to eq('my_shiny_new_command')
          end
          it 'can override command name with multiple env_var' do
            # set env first, or command might not have it in time
            allow(ENV).to receive(:[]).with('ENV1').and_return('wrong')
            allow(ENV).to receive(:[]).with('ENV2').and_return('right')
            command.add_env({:name => 'ENV1'})
            command.add_env({:name => 'ENV2'})
            expect(command.name).to eq('right')
          end
          it 'can override command name with multiple env_var and one not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return('rite')
            allow(ENV).to receive(:[]).with('ENV2').and_return(nil)
            command.add_env({:name => 'ENV1'})
            command.add_env({:name => 'ENV2'})
            expect(command.name).to eq('rite')
          end
          it 'can override command name with multiple env_var and first not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return(nil)
            allow(ENV).to receive(:[]).with('ENV2').and_return('rite')
            command.add_env({:name => 'ENV1'})
            command.add_env({:name => 'ENV2'})
            expect(command.name).to eq('rite')
          end
          it 'raises an error when supplied a bad key' do
            bad_key = :foo
            expect{ command.add_env({bad_key => 'bar'})}.to raise_error(ArgumentError)
          end
        end
        describe 'as block' do
          it 'does not override command name with empty env_var' do
            # set env first, or command might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return(nil)
            command.add_env { |e| e.name = 'BLAH' }
            expect(command.name).to eq(@command_name)
          end
          it 'can override command name with env_var' do
            # set env first, or command might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return('my_shiny_new_command')
            command.add_env { |e| e.name = 'BLAH' }
            expect(command.name).to eq('my_shiny_new_command')
          end
          it 'can override command name with multiple env_var' do
            # set env first, or command might not have it in time
            allow(ENV).to receive(:[]).with('ENV1').and_return('wrong')
            allow(ENV).to receive(:[]).with('ENV2').and_return('right')
            command.add_env { |e| e.name = 'ENV1' }
            command.add_env { |e| e.name = 'ENV2' }
            expect(command.name).to eq('right')
          end
          it 'can override command name with multiple env_var and one not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return('rite')
            allow(ENV).to receive(:[]).with('ENV2').and_return(nil)
            command.add_env { |e| e.name = 'ENV1' }
            command.add_env { |e| e.name = 'ENV2' }
            expect(command.name).to eq('rite')
          end
          it 'can override command name with multiple env_var and first not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return(nil)
            allow(ENV).to receive(:[]).with('ENV2').and_return('rite')
            command.add_env { |e| e.name = 'ENV1' }
            command.add_env { |e| e.name = 'ENV2' }
            expect(command.name).to eq('rite')
          end
        end
      end

      describe '#to_str' do
        it 'returns the name' do
          expect(command.to_s).to eq("#{@command_name} #{@arg_name}")
        end
        # the rest of these perms are covered above, no need to repeat here
        it 'can override command name with env_var' do
          # set env first, or command might not have it in time
          allow(ENV).to receive(:[]).with('BLAH').and_return('my_shiny_new_command')
          command.add_env({:name => 'BLAH'})
          expect(command.to_s).to eq("my_shiny_new_command #{@arg_name}")
        end
      end

      describe '#message' do
        it 'returns the formatted message' do
          @formatted_message = 'killer message'
          expect(command.message).to eq(@formatted_message)
        end
      end
    end

    describe Command do
      it_behaves_like "a Command object" do
        let(:command)  { described_class.new(@args) }
      end
      it_behaves_like "a Command object" do
        let(:command)  { described_class.new(&@block) }
      end
    end

  end
end
