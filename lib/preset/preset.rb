module PureMotion

  class Preset

    def self.build(&block)

      preset = self.new({ :from => :dsl })
      preset.instance_eval(&block) if block_given?

      preset

    end

    attr_accessor :event_handlers

    def initialize(options = {})

      defaults = {
        :from => :dsl,
        :input => nil,
        :output => nil
      }

      options = defaults.merge(options)

      @input = nil
      @output = nil
      @log = nil
      @previous = :general
      @current = :general
      @commands = []
      @event_handlers = {}
      @dsls = [:general, :file, :video, :audio, :metadata ,:crop, :pad]

      input(options[:input]) unless options[:input].nil?
      output(options[:output]) unless options[:output].nil?

      extend_for(:general) if options[:from] == :dsl
    end

    def method_missing(name, *args, &block)
      raise NoMethodError, "No parameter or context '#{name}' in context '#{@current.nil? ? @previous.capitalize : @current.capitalize} transcode parameters'" unless @dsls.include?(name) or args.length != 1
      return false unless block_given?
      extend_for(name)
      instance_eval(&block)
      extend_for @previous
    end

    def arguments
      @commands.join(" ")
    end

    def event(name, &block)
      @event_handlers[name] = block
    end

    def event_handler(name)
      @event_handlers[name] or nil
    end

    def log(log=nil)
      return @log if log.nil?
      @log = log
      true
    end

    def output(output=nil)
      return @output if output.nil?
      return false unless @output.nil?
      output = "\"#{output}\"" if output =~ /\s/ and !(output =~ /^".*"$/)
      @output = output
      add @output
      true
    end

    def input(input=nil)
      return @input if input.nil?
      return false unless @input.nil?
      if input.is_a?(String) then
        if ::File.exists?(input) then # Ruby's File class is hidden by Preset::File
          begin
            @input = PureMotion::Media.new(input)
          rescue PureMotion::UnsupportedFormat
            if event_handler(:failure).nil? then
              raise ArgumentError, "Invalid input file '#{input}'" if event_handler(:failure).nil?
              return false
            else
              event_handler(:failure).call(:invalid_input, "Invalid input file '#{input}'")
              return false
            end
          end
        else
          raise ArgumentError, "Input file '#{input}' not found"
          return false
        end
      else
        if input.is_a?(PureMotion::Media)
          @input = input
          return true
        else
          raise ArgumentError, "Invalid input"
          return false
        end
      end
      raise ArgumentError, "Invalid media input '#{@input.filename}'" unless @input.valid?
      add :i => @input.filename
      true
    end

    private

    def regexp
      {
        :bitrate => /^(\d*)(\S*)$/,
        :resolution => /(\d*)x(\d*)/
      }
    end
    
    def extend_for(dsl)
      return false unless @dsls.include?(dsl)
      @previous = @current
      @current = dsl
      eval("extend(Preset::#{dsl.to_s.capitalize})")
    end

    def add(command)
      @commands << command.strip if command.is_a?(String)
      command = { command => '' } if command.is_a?(Symbol)
      if command.is_a?(Hash) then
        command.each_pair do |switch, value|
          begin
            value = value.to_s.strip
            switch = switch.to_s.strip
            value = "\"#{value}\"" if (value =~ /\s/)
          rescue
            throw ArgumentError, "Parameter enable to be cast to a string"
          end
          @commands << "-#{switch} #{value}".strip
        end
      else false end

    end
    
  end

end
