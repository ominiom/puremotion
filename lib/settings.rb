module PureMotion

  class Settings

    @@settings = {
      :threaded => true
    }

    def self.[]=(name, value)
      @@settings[name] = value
    end

    def self.[](name)
      @@settings[name]
    end

  end

end