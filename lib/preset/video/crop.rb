module PureMotion

  class Preset

    module Crop

      # TODO : Check if crop amounts leave no video showing?

      def top(amount)
        add :croptop => amount
      end

      def right(amount)
        add :cropright => amount
      end

      def bottom(amount)
        add :cropbottom => amount
      end

      def left(amount)
        add :cropleft => amount
      end

    end

  end

end