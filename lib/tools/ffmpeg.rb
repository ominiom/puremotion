module PureMotion::Tools
  
  class FFmpeg < PureMotion::Process
    
    def initialize(arguments)
      super("ffmpeg #{arguments}")
    end
    
    def version
      find_in_ouput(/^FFmpeg version (\S+)/)
    end
    
  end
  
end