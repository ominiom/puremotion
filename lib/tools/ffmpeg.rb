module PureMotion::Tools
  
  class FFmpeg

    attr_reader :pid
    attr_reader :args
    attr_accessor :output
    
    event :line
    event :exited

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
      
        @pio = IO.popen("ffmpeg #{@options} 2>&1")
        @pid = @pio.pid
        @pio.each_byte do |l|
          if l == 10 or l == 13 then
            @output.push temp
            fire(:line, temp)
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
          @pid = nil
          @pio.close
          fire(:exit)
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
    
  end
  
end