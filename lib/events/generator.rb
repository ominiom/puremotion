# ruby-event - generator.rb
# Author    :: Stefan Nuxoll
# License   :: BSD License
# Copyright :: Copyright (C) 2009 Stefan Nuxoll

module PureMotion::Events
  module Generator
  
    # Constructs the methods and objects for an event automatically
    #
    # Example:
    #   event :data_received
    def event(event_name)
      self.class_eval <<-EOT
      
        def #{event_name}(*args, &block)
          _ensure_events
          if not @_events["#{event_name}"]
            @_events["#{event_name}"] = PureMotion::Events::Event.new
          end
          if args != []
            @_events["#{event_name}"].call(self, args)
          else
            if block
              #{event_name} + block
            else
              @_events["#{event_name}"]
            end
          end
        end
        
        def #{event_name}=(event)
          _ensure_events
          if PureMotion::Events::Event === event
            @_events["#{event_name}"] = event
          end
        end
        
        def _ensure_events
          if not @_events
            @_events = {}
          end
        end
        
        private :_ensure_events 
      EOT
    end
    
  end
end
