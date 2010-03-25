module PureMotion

  class Preset

    module Pad

      def top(amount)
        add :padtop => amount
      end

      def right(amount)
        add :padright => amount
      end

      def bottom(amount)
        add :padbottom => amount
      end

      def left(amount)
        add :padleft => amount
      end

      def color(color)
        add :padcolor => color
      end

    end

  end

end