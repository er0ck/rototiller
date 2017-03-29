require 'open3'
require 'rototiller/task/collections/env_collection'
require 'rototiller/task/collections/switch_collection'
require 'rototiller/task/collections/option_collection'
require 'rototiller/task/collections/argument_collection'

module Rototiller
  module Task

    # The Command class to implement rototiller command handling
    #   via a RototillerTask's #add_command
    # @since v0.1.0
    # @attr [String] name The name of the command to run
    # @attr_reader [Struct] result A structured command result
    #    contains members: output, exit_code and pid (from Open3.popen2e)
    class Command < RototillerParam

      # @return [String] the command to be used, could be considered a default
      attr_accessor :name

      # @return [Struct] the command results, if run
      attr_reader :result

      # Creates a new instance of Command, holds information about desired state of a command
      # @param [Hash,Array<Hash>] args hashes of information about the command
      # for block { |b| ... }
      # @yield Command object with attributes matching method calls supported by Command
      # @return Command object
      def initialize(args={}, &block)
        # the env_vars that override the command name
        @env_vars      = EnvCollection.new
        @switches      = SwitchCollection.new
        @options       = OptionCollection.new
        @arguments     = ArgumentCollection.new

        block_given? ? (yield self) : send_hash_keys_as_methods_to_self(args)
        # @name is the default unless @env_vars returns something truthy
        (@name = @env_vars.last) if @env_vars.last
      end

      # adds environment variables to be tracked, messaged.
      #   In the Command context this env_var overrides the command "name"
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      #                                  this is optional and defaults to the parent's `:name`
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys described above
      def add_env(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          # send in the name of this Param, so it can be used when no default is given to add_env
          @env_vars.push(EnvVar.new({:parent_name => @name},&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            # send in the name of this Param, so it can be used when no default is given to add_env
            arg[:parent_name] = @name
            @env_vars.push(EnvVar.new(arg))
          end
        end
        @name = @env_vars.last if @env_vars.last
      end

      # adds switch(es) (binary option flags) to this Command instance with optional env_var overrides
      # @param [Hash] args hashes of information about the switch
      # @option args [String] :name The switch string, including any '-', '--', etc
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys described above
      def add_switch(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @switches.push(Switch.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @switches.push(Switch.new(arg))
          end
        end
      end

      # adds option to append to command (a switch with an argument)
      #   add_option creates an option object which has its own `#add_env`, `#add_argument` methods
      # @param [Hash] args hashes of information about the option
      # @option args [String] :name The value to be used as the option
      # @option args [String] :message A message describing the use of option
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the option, available methods match hash keys
      def add_option(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @options.push(Option.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @options.push(Option.new(arg))
          end
        end
      end

      # adds argument to append to command.
      #   In the Command context this Argument is added to the end of the command string
      # @param [Hash] args hashes of information about the argument
      # @option args [String] :name The value to be used as the argument
      # @option args [String] :message A message describing the use of argument
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the option, available methods match hash keys
      def add_argument(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        if block_given?
          @arguments.push(Argument.new(&block))
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @arguments.push(Argument.new(arg))
          end
        end
      end

      # convert a Command object to a string (runable command string)
      # @return [String] the current value of the command string as built from its params
      # TODO make private method? so that it will throw an error if yielded to?
      def to_str
        delete_nil_empty_false([
          (name if name),
          @switches.to_s,
          @options.to_s,
          @arguments.to_s
        ]).join(' ').to_s
      end
      alias :to_s :to_str

      Result = Struct.new(:output, :exit_code, :pid)
      # run Command locally, capture relevent result data
      # @return [Struct<Result>] a Result Struct with stdout, stderr, exit_code members
      # TODO make private method? so that it will throw an error if yielded to?
      def run
        # make this look a bit like beaker's result class
        #   we may have to convert this to a class if it gets complex
        # QA-2851: DO NOT use open3, Kernel#`, %x{}, Kernel#exec to run the command
        #   Kernel#exec doesn't return.  the others do not pass execution to a sub-shell to allow user interaction
        #     we need to use system here so a user can arbitrarily interact with the process
        #     (if they put a pry breakpoint in the downstream code, for instance)
        #   because we used to return meaningful output, and pid, this is a breaking change
        @result = Result.new
        @result.output = ''
        command_found = system(self.to_str)
        @result.pid = $?.pid
        @result.exit_code = $?.exitstatus
        unless command_found
          @result.output    = 'doesnotexist: command not found'
        end

        if block_given? # if block, send result to the block
          yield @result
        end
        return @result
      end

      # Does this param require the task to stop
      # Determined by the interactions between @name, @env_vars, @options, @switches, @arguments
      # @return [true|nil] if this param requires a stop
      # TODO make private method? so that it will throw an error if yielded to?
      def stop
        return true if [@switches, @options, @arguments].any?{ |collection| collection.stop? }
        return true unless @name
      end

      # @return [String] formatted messages from all of Command's pieces
      #   itself, env_vars, switches, options, arguments
      # TODO make private method? so that it will throw an error if yielded to?
      def message
        return [@message,
                @env_vars.messages,
                @switches.messages,
                @options.messages,
                @arguments.messages,
        ].join('')
      end

      private
      # @private
      def delete_nil_empty_false(arg)
        arg.delete_if{ |i| ([nil, '', false].include?(i)) }
      end
    end

  end
end
