def Transcode(*args, &block)

  raise ArgumentError, "No block given for transcode preset" unless block_given?

  preset = PureMotion::Preset.new(:dsl)
  preset.instance_eval(&block)

  options = {
    :input => preset.input,
    :output => preset.output,
    :preset => preset
  }

  options[:log] = preset.log unless preset.log.nil?

  transcode = PureMotion::Transcode::Transcode.new(options)

  transcode.run

  return transcode

end

module PureMotion::Transcode
  
  class Transcode < Object

    event :progress
    event :complete
    event :output
    
    @ffmpeg = nil
    @input = nil
    
    def initialize(options)
      
      default_options = {
        :output => nil,
        :preset => nil,
        :input => nil
      }
      
      raise ArgumentError, "Invalid transcode parameters given" unless options.is_a?(Hash)
      
      options = default_options.merge(options)
      
      raise ArgumentError, "No output file given" if options[:output].nil?

      if options[:input].is_a?(String) then
        @input = PureMotion::Media.new(options[:input])
      else
        @input = options[:input]
      end
      @preset = options[:preset]
      @output = options[:output]

      validate

      wire_events

      if options[:log] then
        @log = File.new(options[:log], 'w')
        self.output + lambda do |t, line|
          @log.puts line
        end
        self.complete + lambda do |t, complete|
          @log.close
        end
      end
      
      # Raise error if output file exists and overwrite not set
      
      @ffmpeg = PureMotion::Tools::FFmpeg.new(:options => @preset.arguments)
	
      @ffmpeg.line + lambda do |ffmpeg, line|
        handle_output line
      end

      @ffmpeg.exited + lambda do |ffmpeg, exited|
        complete(true)
      end
      
    end
    
    def run
      @ffmpeg.run
    end
    
    def cancel
      # TODO : Implement
    end
    
    def cancel!
      # TODO : Implement - kill process dead
    end
    
    private
    
    def handle_output line
      output line
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
      if line[4].to_i == 0 then return false end
      p = {
        :frame    => line[1].to_i,
        :fps      => line[2].to_i,
        :q        => line[3].to_f,
        :size     => line[4].to_i,
        :time     => line[6].to_f,
        :bitrate  => line[7].to_f,
        :percent  => ((100.00 / @input.duration) * line[6].to_f).to_i
      }
      p[:percent] = 100 if p[:percent] > 100 unless p[:percent].nil?
      progress(p)
    end
    
    def validate
      
    end

    def wire_events
      self.complete += @preset.event_handlers[:complete] unless @preset.event_handlers[:complete].nil?
      self.progress += @preset.event_handlers[:progress] unless @preset.event_handlers[:progress].nil?
    end

  end
  
  
end
