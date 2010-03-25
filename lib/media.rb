def Media(*args, &block)

  raise ArgumentError, "No arguments given" unless args.length > 0
  raise ArgumentError, "Invalid file parameter" unless args[0].is_a?(String)

  path = args[0]

  # PureMotion::Media will handle testing if the file exists
  media = PureMotion::Media.new(path)

  media.instance_eval(&block) if block_given?

  media

end

module PureMotion

  class Media

    # Has the media at least one video stream?
    #
    # @return [Boolean] Existance of a video stream
    def video?
      has_stream_of :video
    end

    # Has the media at least one audio stream?
    #
    # @return [Boolean] Existance of an audio stream
    def audio?
      has_stream_of :audio
    end

    # Convience method to return the first video stream in the media.
    #
    # @return [PureMotion::Streams::Stream, nil] Video stream object or nil if no video stream is found.
    def video
      first_stream_of :video
    end

    # Convience method to return the first audio stream in the media.
    #
    # @return [PureMotion::Streams::Stream, nil] Audio stream object or nil if no audio stream is found.
    def audio
      first_stream_of :audio
    end

    # Determines if the file cannot be read by FFmpeg
    # @return [Boolean]
    def invalid?
      !valid?
    end

    # Returns the first stream of `type`
    # @param [Symbol] type The type of stream - `:video` or `:audio`
    # @return [PureMotion::Streams::Stream, nil] First stream of `type` or nil if one is not found
    def first_stream_of( type )
      streams.each do |stream| return stream if stream.type == type end
      return nil
    end

    # Has the media a stream of `type`?
    # @param [Symbol] type The type of stream - `:video` or `:audio`
    # @return [Boolean]
    def has_stream_of( type )
      has = false
      streams.each do |stream| has = true if stream.type == type end
      return has
    end

  end

end
