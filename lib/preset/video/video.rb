module PureMotion

  class Preset

    module Video

      def buffer(size)
        add :bufsize => size
      end

      def disable
        add :vn
      end

      def frames(frames)
        # TODO : Check whole number etc
        add :vframes => frames
      end

      def framerate(fps)
        add :r => fps
      end

      alias :fps :framerate

      def aspect_ratio(ratio)
        if ratio.is_a?(String)
          ratio = ratio.split(':')[0..1]
          fail ArgumentError, "Invalid aspect ratio" unless ratio.length == 2
          begin
            ratio = ratio[0].to_f / ratio[1].to_f
          rescue
            fail(ArgumentError, "Invalid aspect ratio")
          end
        end
        if ratio.is_a?(Fixnum)
          fail ArgumentError, "Invalid aspect ratio" unless ratio >= 1 and ratio <= 2
        else fail ArgumentError, "Invalid aspect ratio" end

        add :aspect => ratio
      end

      def same_quality
        add "-sameq"
      end

      def codec(codec)
        add :vc => "#{codec}"
      end

      def bitrate(rate)
        fail ArgumentError, "Invalid bitrate" unless rate.to_s =~ regexp[:bitrate]
        add :vb => rate
      end

      def resolution(*res)
        res_regexp = regexp[:resolution]
        res_invalid = ArgumentError.new("Resolution invalid")
        presets = {
          'sqcif'  => [128,    96  ],
          'qcif'   => [176,    144 ],
          'cif'    => [352,    288 ],
          '4cif'   => [704,    576 ],
          'qqvga'  => [160,    120 ],
          'qvga'   => [320,    240 ],
          'vga'    => [640,    480 ],
          'svga'   => [800,    600 ],
          'ga'     => [1024,   768 ],
          'uga'    => [1600,   1200],
          'qga'    => [2048,   1536],
          'sga'    => [1280,   1024],
          'qsga'   => [2560,   2048],
          'hsga'   => [5120,   4096],
          'wvga'   => [852,    480 ],
          'wga'    => [1366,   768 ],
          'wsga'   => [1600,   1024],
          'wuga'   => [1920,   1200],
          'woga'   => [2560,   1600],
          'wqsga'  => [3200,   2048],
          'wquga'  => [3840,   2400],
          'whsga'  => [6400,   4096],
          'whuga'  => [7680,   4800],
          'cga'    => [320,    200 ],
          'ega'    => [640,    350 ],
          'hd480'  => [852,    480 ],
          'hd720'  => [1280,   720 ],
          'hd1080' => [1920,   1080]
        }
        raise ArgumentError, "No resolution given" if res.empty?

        # Transform things like resolution(:hd1080)
        if res.length == 1 then
          res = "#{res[0]}" if res[0].is_a?(String) or res[0].is_a?(Symbol)
        end

        # Handle call like - resolution(320, 240)
        res = "#{res[0]}x#{res[1]}" if res.length == 2

        # Handle call like - resolution([320, 240])
        res = res[0] if res[0].is_a?(Array)

        # Handle strings like 'vga' or '320x240'
        if res.is_a?(String) then
          if presets.include?(res) then
            res = presets[res]
          else
            res = res_regexp.match(res).captures[0..1] if res =~ res_regexp
          end
        end

        fail res_invalid unless res.is_a?(Array)
        fail res_invalid unless res.length == 2

        begin
          res = res.collect { |dimension| dimension.to_i }
        rescue
          fail res_invalid
        end

        fail res_invalid unless res[0].is_a?(Integer) and res[1].is_a?(Integer)

        add :s => res.join("x")

      end

    end

  end

end