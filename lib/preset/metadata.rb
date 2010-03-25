module PureMotion

  class Preset

    module Metadata

      def title(title)
        add :title => title
      end

      def author(author)
        add :author => author
      end

      alias :artist :author

      def copyright(copyright)
        add :copyright => copyright
      end

      def album(album)
        add :album => album
      end

      def year(year)
        add :year => year
      end

      def track(track)
        add :track => track
      end

      def comment(comment)
        add :comment => comment
      end

    end

  end

end