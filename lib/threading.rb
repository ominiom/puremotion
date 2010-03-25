# Author:: Jared Kuolt (mailto:me@superjared.com)
# Copyright:: Copyright (c) 2009 Jared Kuolt
# License:: MIT License
#
# See README.rdoc[link:files/README_rdoc.html] for usage
#

module PureMotion
  class Thread

    attr_reader :thread, :exception
    attr_accessor :name
  
    def initialize(config={}, &block)
      args = (config[:args] or [])
      self.class.init_exit_handler
      @thread = ::Thread.new(*args) do |*targs|
        begin
          block.call(*targs)
        rescue Exception => e
          @exception = e
          # Handle?
        end
      end
      self.name = config[:name] || @thread.inspect
      self.class.threads << self
      self.class.init_exit_handler
    end

    class << self
      attr_accessor :logger, :exit_thread, :exit_handler_initialized, :callbacks

      def threads
        @threads ||= []
      end
  
      def init_exit_handler
        return if self.exit_handler_initialized
        self.exit_thread = false
        at_exit do
          self.exit_thread = true
          begin
            self.threads.each do |thread|
              thread.thread.join
            end
          rescue Interrupt
          end
        end
        self.exit_handler_initialized = true
      end
  
    end
  end
end