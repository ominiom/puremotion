module PureMotion

  class Preset

    module General

      def overwrite!
        add "-y"
      end

      def seek(position)
        add :ss => "#{position}"
        # TODO : If input file is given check that seek distance is not greater than length
      end

      def duration(time)
        add :t => time
      end

      def offset(by)
        add :itsoffset => by
      end

    end

  end
  
end