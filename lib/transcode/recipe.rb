require 'yaml'

module PureMotion::Transcode
  
  class Recipe
    
    def self.from_file(file)

      raise(ArgumentError, "Recipe file '#{file}' not found") unless File.exists?(file)
      
      return self.new({ :source => :file, :recipe => file })
    end
    
    def self.from_name(name)
      
      n = name.to_s
      
      raise(ArgumentError, 'Invalid recipe name') if not n.is_a?(String) 
      
      return from_file(n)
      
    end
    
    def self.build(hash)
      return self.new({ :source => :hash, :recipe => hash})
    end
    
    @recipe = {
      'format' => :skip
    }
    @opt = {}
    @video = {}
    @audio = {}
    @container = nil
    @cmd = nil
    
    attr_accessor :audio, :video, :arg_string, :args
    
    def initialize(opts)
      
      if not opts.is_a? Hash then raise(ArgumentError, "opts should be a hash") end
        
      defaults = {
        :source => :hash,
        :recipe => nil
      }
      
      @opts = defaults.merge!(opts)
      
      @recipe = @opts[:recipe]
      
      if @recipe.nil? then raise(ArgumentError, "No recipe given") end
      
      case @opts[:source]
        when :hash
          hash_build
        when :file
          file_build @recipe
        when :name
          from_name @recipe
        else
          raise(ArgumentError, 'Invalid recipe source')
      end
    
    end
  
    def parse o
      
      recipe = nil
      
      recipe = o['recipe'] if o.has_key? 'recipe'
      recipe = o if o.has_key? 'video' or o.has_key? 'audio'
      
      raise ArgumentError, 'Bad recipe' if recipe.nil?

      if recipe.has_key? 'cmd' then
        @cmd = recipe['cmd']
        return true
      end

      video = recipe['video']
      audio = recipe['audio']
      
      parse_video = lambda do |source_video|
        
        @video = {}
        @video.merge! source_video
        
        # Video codec
        if @video['codec'].nil? then @video['codec'] = :skip else
          raise ArgumentError, 'Recipe: Invalid Video Codec' unless PureMotion::Codecs.valid? @video['codec'], :video
          @video['codec'] = PureMotion::Codecs.find(@video['codec']).ffmpeg_name
        end
        # End video codec

        # Video bitrate
        if @video['bitrate'].nil? then @video['bitrate'] = :skip else
          begin
            @video['bitrate'] = @video['bitrate'].to_i if not @video['bitrate'].is_a? Integer
          rescue
            raise ArgumentError, 'Video bitrate must be a number'
          end
          
          @video['bitrate'] *= 1024
          raise ArgumentError, 'Recipe: video bitrate too low' if @video['bitrate'] < 1024
        end
        # End video
        
        # Video resolution
        if @video['resolution'].nil? then @video['resolution'] = :skip else
          if not @video['resolution'] =~ /\d*x\d*/ then
            raise ArgumentError, "Invalid resolution"
          end
        end
        # End video resolution
        
        
        
      end
      
      parse_audio = lambda do |source_audio|
        
        @audio = {
          'codec' => nil,
          'bitrate' => nil,
        }
        
        @audio.merge! source_audio
        
        # Audio codec
        if @audio['codec'].nil? then @audio['codec'] = :skip else
          raise ArgumentError, 'Recipe: Invalid Audio Codec' unless PureMotion::Codecs.valid? @audio['codec'], :audio
          @audio['codec'] = PureMotion::Codecs.find(@audio['codec']).ffmpeg_name
        end
        # End Audio codec
        
        # Audio bitrate
        if @audio['bitrate'].nil? then @audio['bitrate'] = :skip else
          begin
            @audio['bitrate'] = @audio['bitrate'].to_i if not @audio['bitrate'].is_a? Integer
          rescue
            raise ArgumentError, 'Audio bitrate must be a number'
          end
          
          @audio['bitrate'] *= 1024
          raise ArgumentError, 'Recipe: Audio bitrate too low' if @audio['bitrate'] < 1024
        end
        # End Audio Bitrate
        
        # Audio channels
        if @audio['channels'].nil? then @audio['channels'] = :skip else
          channel_types = { 'mono' => 1, 'stereo' => 2 }
          if @audio['channels'].is_a? String then
            @audio['channels'].downcase!
            if channel_types[@audio['channels']].nil? then
              @audio['channels'] = :skip
            else
              @audio['channels'] = channel_types[@audio['channels']]
            end
          end
        end
        # End audio channels
        
      end
      
      parse_video.call video unless video.nil?
      parse_audio.call audio unless audio.nil?
      
      @recipe = {}
      
      if recipe['format'].nil? then recipe['format'] = :skip else
        @recipe.store('format', recipe['format'])
      end
      
    end
  
    def valid?
      valid = true
      if audio? and !valid_audio? then valid = false end
      if video? and !valid_video? then valid = false end
      valid
    end
  
    def valid_video?
      
    end
  
    def valid_audio?
      
    end
  
    def to_args(opts = {})

      cmd = @cmd

      if !cmd.nil? then
        opts.each_pair { |key, value| cmd.sub!('#{' + key.to_s + '}', value.to_s) }
        return cmd
      end

      args = []
      arg_strings = []
      
      args[0] = ['f',       @recipe['format']   ]
      args[1] = ['acodec',  @audio['codec']     ]
      args[2] = ['vcodec',  @video['codec']     ]
      args[3] = ['vb',      @video['bitrate']   ]
      args[4] = ['s',       @video['resolution']]
      args[5] = ['r',       @video['fps']       ]
      args[6] = ['ab',      @audio['bitrate']   ]
      args[7] = ['ac',      @audio['channels']  ]
      required_value_args = ['f', 'vcodec', 'acodec', 'vb', 's', 'r', 'ab', 'ac']
      
      args.each do |arg|
        next if required_value_args.include? arg[0] and arg[1].nil?
        arg_strings << format_arg(arg[0], arg[1])
      end
      
      @args = arg_strings.join(' ')
      
      puts @args

      @args
      
    end
  
    private
    
    def format_arg name, value
      name = '' if name.nil?
      value = '' if value.nil?
      value = value.to_s
      value.gsub! '"', ''
      value = '"' + value + '"' if value =~ /\s/
      return value if name == :non
      return name if value == :non
      '-' + name.to_s + ' ' + value.to_s
    end
    
    def hash_build
      
    end
    
    def file_build(file)
      @yaml = ::YAML.load( File.read(file) )
      parse @yaml
    end
    
  end
  
end
