module PureMotion

  class Preset

    def self.build(&block)

      preset = self.new(:dsl)
      preset.instance_eval(&block) if block_given?
      puts preset.arguments

      preset

    end

    def initialize(form=nil)
      @previous = :general
      @current = :general
      @commands = []
      @dsls = [:general, :file, :video, :audio, :metadata ,:crop, :pad]
      extend_for(:general) if form == :dsl
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
