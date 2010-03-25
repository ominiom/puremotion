module PureMotion::Transcode
  
  @@recipes = []
  
  def self.do(media, params)
    return Transcode.new(media, params)
  end
  
  class Transcode < Object

    attr_reader :ffmpeg

    event :progress
    event :complete
    event :error
    event :status_change
    event :output    

    @status
    @media = nil
    
    @ffmpeg = nil

    def ffmpeg
      return nil unless !@ffmpeg.nil?
      @ffmpeg
    end
    
    def initialize(media, params)
      
      @status = Status::NOT_STARTED
      
      @params = {
        :output => nil,
        :overwrite => false,
        :recipe => nil
      }
      
      raise ArgumentError, "Invalid paramters given" unless params.is_a? Hash
      
      @params.merge!(params)
      
      raise ArgumentError, "No output file given" if @params[:output].nil?
      
      case @params[:recipe]
      when String
        set_recipe Recipe.from_file(@params[:recipe])
      when Hash
        set_recipe Recipe.build(@params[:recipe])
      when Recipe
        set_recipe @params[:recipe]
      when Symbol
        set_recipe Recipe.from_name(@params[:recipe].to_s)
      else
        raise ArgumentError, "Invalid recipe"
      end

      @media = find_media(media)

      if @params[:log] then
        @log = File.new(params[:log], 'w')
        self.output + lambda do |t, line|
          @log.puts line
        end
        self.complete + lambda do |t, complete|
          @log.close
        end
      end
      
      raise ArgumentError, "Output file #{@params[:output]} exists and overwrite disabled" if File.exists?(@params[:output]) and !@params[:overwrite]
      
      @ffmpeg = PureMotion::Tools::FFmpeg.run :options => "-i #{@media.filename} #{'-y' if @params[:overwrite]} " + @recipe.to_args + " \"#{@params[:output]}\""
	
      @ffmpeg.line + lambda do |ffmpeg, line|
        handle_output line
      end

      @ffmpeg.exited + lambda do |ffmpeg, exited|
        complete(true)
      end
      
    end
    
    def run
      
    end
    
    def cancel
      
    end
    
    def cancel!
      
    end
    
    private
    
    def set_recipe(recipe)
      @params[:recipe] = recipe
      @recipe = recipe
    end
    
    def set_status(status)
      @status = status
      status_change(@status)
    end
  
    def find_media(media)
      
      case media
      when String
        return PureMotion::Media.new(media)
      when PureMotion::Media
        return media
      else
        raise Error, "Invalid media given"
      end
      
    end
    
    def handle_output line
      output line
      # /^frame=\s*(?<frame>\d*)\s*fps=\s*(?<fps>\d*)\s*q=(?<q>\S*)\s*size=\s*(?<size>[\d]*)(?<size_unit>[kmg]B)\s*time=\s*(?<time>[\d.]*)\s*bitrate=\s*(?<bitrate>[\d.]*)(?<bitrate_unit>[km]b).*$/
      progress_line = /frame=\s*(\d*)\s*fps=\s*(\d*)\s*q=(\S*)\s*[L]?size=\s*([\d]*)([kmg]B)\s*time=\s*([\d.]*)\s*bitrate=\s*([\d.]*)([km]b)/
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
        :percent  => ((100.00 / @media.duration) * line[6].to_f).to_i
      }
      p[:percent] = 100 if p[:percent] > 100 unless p[:percent].nil?
      progress(p)
    end
    
    # Fire progress event
    # complete(p)
  end
  
  class Error < Exception
      
  
  end  
  
  class Status
    
    NOT_STARTED = -1
    
  end
  
end
