def Transcode(*args, &block)

  raise ArgumentError, "No block given for transcode preset" unless block_given?

  preset_options = {
    :from => :dsl
  }

  preset_options[:input] = args[0] || nil

  preset = PureMotion::Preset.new(preset_options)
  preset.instance_eval(&block)

  transcode_options = {
    :preset => preset
  }

  transcode_options[:log] = preset.log unless preset.log.nil?

  transcode = PureMotion::Transcode::Transcode.new(transcode_options)

  if transcode.valid? then
    transcode.run
    return transcode
  else
    return false
  end

end

module PureMotion::Transcode
  
  class Transcode

    event :progress
    event :complete
    event :output
    event :failure

    def initialize(options)

      @valid = true # Until it all goes wrong

      # Default everything to nil
      default_options = {
        :output => nil,
        :preset => nil,
        :input => nil
      }
      
      raise ArgumentError, "Invalid transcode parameters given" unless options.is_a?(Hash)
      
      options = default_options.merge(options)

      @preset = options[:preset]

      wire_events

      @input = (@preset.input || options[:input])
      validate_input
      
      @output = File.expand_path(@preset.output || options[:output])
      validate_output

      @ffmpeg = PureMotion::Tools::FFmpeg.new(@preset.arguments)

      if options[:log] then
        @log = File.new(options[:log], 'w')
        on(:output) do |line|
          @log.puts line
        end
        @ffmpeg.on(:exit) do
          @log.close
        end
      end

      @ffmpeg.on(:output) do |line|
        handle_output line
      end

      @ffmpeg.on(:exit) do
        handle_exit
      end

    end

    def valid?
      return @valid
    end
    
    def run
      raise ArgumentError, "Transcode is invalid" unless valid?
      @ffmpeg.run
    end
    
    def cancel
      # TODO : Implement
    end
    
    def cancel!
      # TODO : Implement - kill process dead
    end
    
    private

    def invalidate!
      @valid = false
    end

    def handle_exit
      if !File.exists?(@output) then
        fire(:failure, :output_missing)
        return
      end
      begin
        output_media = Media(@output)
        fire(:complete, output_media) if output_media.valid?
      rescue PureMotion::UnsupportedFormat
        fire(:failure, :transcode_unreadable)
        return
      end
    end

    def handle_output line
      fire(:output, line)
      # /^frame=\s*(?<frame>\d*)\s*fps=\s*(?<fps>\d*)\s*q=(?<q>\S*)\s*size=\s*(?<size>[\d]*)(?<size_unit>[kmg]B)\s*time=\s*(?<time>[\d.]*)\s*bitrate=\s*(?<bitrate>[\d.]*)(?<bitrate_unit>[km]b).*$/
      progress_line = /frame=\s*(\d*)\s*fps=\s*(\d*)\s*q=(\S*)\s*[L]?size=\s*([\d]*)([kmg]B)\s*time=\s*([\d.]*)\s*bitrate=\s*([\d.]*)([km]b)/
      # The regex is documentated above and the matches it should give below
      # 1 => frame
      # 2 => fps
      # 3 => q
      # 4 => size
      # 5 => size_unit
      # 6 => time
      # 7 => bitrate
      # 8 => bitrate_unit
      handle_progress(progress_line.match(line)) if progress_line.match(line)
    end
    
    def handle_progress line
      progress = {
        :frame    => line[1].to_i,
        :fps      => line[2].to_i,
        :q        => line[3].to_f,
        :size     => line[4].to_i,
        :time     => line[6].to_f,
        :bitrate  => line[7].to_f,
        :percent  => ((100.00 / @input.duration) * line[6].to_f).to_i
      }
      progress[:percent] = 100 if progress[:percent] > 100 unless progress[:percent].nil?
      fire(:progress, self, progress)
    end
    
    def validate_input
      if @input.is_a?(String) then
        begin
          @input = Media @input
        rescue PureMotion::UnsupportedFormat
          make_fail(:invalid_input, "Invalid input '#{@input}'")
        end
      end
      if @input.is_a?(PureMotion::Media) then
        make_fail(:invalid_input, "Invalid input '#{@input}'") unless @input.valid?
      end
    end

    def validate_output
      make_fail(:invalid_output, "No output file given") if @output.nil?
      # TODO : Check if output file exists and overwite not set
      make_fail(:invalid_output, "Output file '#{@output}' not writable") unless File.writable?(File.dirname(@output))
    end

    def make_fail(reason=:unknown,message="Unknown reason")
      #invalidate!
      if @preset.event_handler(:failure).nil? then
        raise ArgumentError, message
      else
        fire(:failure, reason, message)
      end
    end

    def wire_events
      @preset.event_handlers.each_pair do |event, handler|
        on(event) + handler
      end
    end

  end
  
  
end
