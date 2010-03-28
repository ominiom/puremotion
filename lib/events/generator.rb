module PureMotion
  module Events
    module Generator

      def event(event_name)
        @@_events_built = false unless class_variable_defined?(:@@_events_built)
        self._build_events unless @@_events_built
      end

      def _build_events
        self.class_eval do

          def on(event_name, &block)
            @_events = {} unless instance_variable_defined?(:@_events)
            @_events[event_name] = PureMotion::Events::Event.new unless @_events[event_name]
            return @_events[event_name] unless block_given?
            @_events[event_name] + block
          end

          def fire(event_name, *args)
            @_events = {} unless instance_variable_defined?(:@_events)
            @_events[event_name].call(*args) unless @_events[event_name].nil?
          end

        end
        @@_events_built = true
      end

    end
  end
end
