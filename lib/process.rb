module PureMotion

  class Process

    event :start
    event :exit
    event :output

    def initialize(options = {})

      defaults = {
        :command => nil,
        :autostart => false
      }

      options = { :command => options } if options.is_a?(String)

      options = defaults.merge(options)

      @command = options[:command]

      raise ArgumentError, "No command given" if @command.nil?

      @status = :ready
      @buffer = ''
      @output = []
    end

    def run
      @status = :running

      @process = IO.popen("#{@command} 2>&1")
      @id = @process.pid

      runner = lambda {
        @process.each_byte { |byte|
          @process.closed? ? handle_exit : handle_output(byte)
        }
      }

      if PureMotion::Settings[:threaded] then
        PureMotion::Thread.new { runner.call }
      else
        runner.call
      end

    end

    def kill!
      
    end

    private

    def find_in_output(regexp)
      return '' if @status == :ready
      m = regexp.match(@output.join('\n'))
      return m[1] if m
      nil
    end

    def handle_output(byte)
      if [10, 13].include?(byte) then
        @output << @buffer
        fire(:output, @buffer)
        @buffer = ''
      else
        byte = byte.chr.to_s
        @buffer = @buffer + byte
      end
    end

    def handle_exit
      @status = :exited
      @id = nil
      @process.close
      fire(:exit)
    end

  end

end