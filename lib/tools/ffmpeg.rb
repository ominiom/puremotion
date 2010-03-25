module PureMotion::Tools
  
  class FFmpeg
    
    class Status
      
      NOT_STARTED       = 1
      INITIALIZING      = 2
      ANALYZING         = 4
      PREPARING_OUTPUT  = 8
      ENCODING          = 16
      ERROR             = 32
      
    end

    attr_reader :pid
    attr_reader :args
    attr_accessor :output
    
    event :line
    event :complete
    event :exited
    event :status_change

    @pid = nil
    
    def initialize(params = {})
      if params.class != Hash then raise ArgumentError, "Invalid parameters" end
      
      @defaults = {
        :ffmpeg => 'ffmpeg',
        :options => nil
      }
      
      @params = params
      
      @options = @params[:options]
      
      if @options.nil? then
        raise ArgumentError, "No options given"
      end
      
      @output = []
    end
    
    def run

      temp = ''
      
      @thread = PureMotion::Thread.new do
        @pio = IO.popen("ffmpeg #{@options} 2>&1")
        @pid = @pio.pid
        @pio.each_byte do |l|
          if l == 10 or l == 13 then
            @output.push temp
            line(temp)
            temp = ''
            l = ''
          else
            l = l.chr
          end
          temp = temp + l
          #@output << l.gsub("\r","\n")
        end
        if @pio.eof? then
          @done = true
          complete(true)
          @pid = nil
          @pio.close
          exited(true)
        end
      end
    
    end
    
    def ran?
      @pio.eof? unless @pio.nil?
      false
    end
    
    def ended?
      return false unless ran?
      @pio.eof?
    end
    
    def version
      return nil unless ran?
      find(/^FFmpeg version (\S+)/)
    end
    
    def find(regexp)
      m = regexp.match(@output)
      return m[1] if m
      nil
    end
    
    def status
      @status
    end
    
  end
  
end