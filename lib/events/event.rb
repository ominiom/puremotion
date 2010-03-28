# ruby-event - event.rb
# Author    :: Stefan Nuxoll
# License   :: BSD License
# Copyright :: Copyright (C) 2009 Stefan Nuxoll

require 'thread'

module PureMotion::Events

  class Event
    
    # Creates a new instance of event, optionally passing in an already created
    # array of handlers for the event
    def initialize(handlers = [], named_handlers = {})
      @handlers       = handlers
      @named_handlers = named_handlers
      
      @handlers_lock       = Mutex.new
      @named_handlers_lock = Mutex.new
    end
    
    # Returns a new Event object with a new handler added,
    def +(handler)
      @handlers_lock.synchronize do
        @handlers << handler
      end
    end
    
    # Creates a new named handler (you can unregister these later without
    # affecting other handlers)
    def subscribe(name, &block)
      @named_handlers_lock.synchronize do
        @named_handlers[name] = block
      end
    end
    
    # Removes a named handler from the event
    def unsubscribe(name)
      @named_handlers_lock.synchronize do
        @named_handlers.delete(name)
      end
    end
    
    # Calls all of the handlers for the events, with the given sender and set
    # of arguments.
    def call(*args)
      # Make sure we don't get surprised with new friends while we're calling
      # the handlers
      named_handlers = @named_handlers
      handlers       = @handlers
    
      named_handlers.each do |name, handler|
        handler.call(*args)
      end
      handlers.each do |handler|
        handler.call(*args)
      end
    end
    
    # Clears the list of anonymous handlers
    def clear!
      @handlers_lock.synchronize do
        @handlers       = []
      end
    end
    
  end
  
end
