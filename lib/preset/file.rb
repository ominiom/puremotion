module PureMotion

  class Preset

    module File

      def overwrite!
        add :y
      end

      def size_limit(size)
        add :fs => size
      end

    end

  end

end
