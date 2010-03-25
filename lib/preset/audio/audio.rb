module PureMotion

  class Preset

    module Audio

      def channels(n)
        add :ac => n
      end

      def frames(frames)
        add :aframes => frame
      end

      def sampling(rate)
        add :ar => rate
      end

      alias :sample_rate :sampling

      def disable
        add :an
      end

      def codec(codec)
        add :ac => codec
      end

      def language(code)
        add :alang => code
      end

      def bitrate(rate)
        fail ArgumentError, "Invalid bitrate" unless rate =~ @@regexp[:bitrate]
        add :ab => rate
      end

    end

  end

end