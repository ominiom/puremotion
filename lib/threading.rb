# Author:: Jared Kuolt (mailto:me@superjared.com)
# Copyright:: Copyright (c) 2009 Jared Kuolt
# License:: MIT License
#
# See README.rdoc[link:files/README_rdoc.html] for usage
#
require 'logger'
require 'timeout'

module PureMotion
  class Thread
    # The Thread object, brah
    attr_reader :thread
    # If the Thread takes a poopie...
    attr_reader :exception
    # An identifier
    attr_accessor :label
  
    # Create a new RobustThread (see README)
    def initialize(opts={}, &block)
      self.class.send :init_exit_handler
      args = (opts[:args] or [])
      self.class.send :do_before_init
      @thread = ::Thread.new(*args) do |*targs|
        begin
          self.class.send :do_before_yield
          block.call(*targs)
          self.class.send :do_after_yield
        rescue Exception => e
          @exception = e
          self.class.send :handle_exception, e
        end
        self.class.log "#{self.label.inspect} exited cleanly"
      end
      self.label = opts[:label] || @thread.inspect
      self.class.group << self
    end
  
    ## Class methods and attributes
    class << self
      attr_accessor :logger, :say_goodnight, :exit_handler_initialized, :callbacks
      VALID_CALLBACKS = [:before_init, :before_yield, :after_yield, :after_join, :before_exit]
  
      # Logger object (see README)
      def logger
        @logger ||= Logger.new(STDOUT)
      end
  
      # Simple log interface
      def log(msg, level=:info)
        self.logger.send level, "#{self}: " + msg
      end
  
      # The collection of RobustThread objects
      def group
        @group ||= [] 
      end
  
      # Loop an activity and exit it cleanly (see README)
      def loop(opts={}, &block)
        sleep_seconds = opts.delete(:seconds) || 2
        self.new(opts) do |*args|
          Kernel.loop do
            break if self.say_goodnight
            block.call(*args)
            # We want to sleep for the right amount of time, but we also don't
            # want to wait until the sleep is done if our exit handler has been
            # called so we iterate over a loop, sleeping only 0.1 and checking
            # each iteration whether we need to die, and the timeout is a noop
            # indicating we need to continue.
            begin
              Timeout.timeout(sleep_seconds) do
                Kernel.loop do
                  break if self.say_goodnight
                  sleep 0.1
                end
              end
            rescue Timeout::Error
              # OK
            end
          end
        end
      end
  
      # Set exception handler
      def exception_handler(&block)
        unless block.arity == 1
          raise ArgumentError, "Bad arity for exception handler. It may only accept a single argument"
        end
        @exception_handler = block
      end
  
      # Add a callback
      public 
      def add_callback(sym, &block)
        sym = sym.to_sym
        raise ArgumentError, "Invalid callback #{sym.inspect}" unless VALID_CALLBACKS.include? sym
        self.callbacks ||= {}
        self.callbacks[sym] ||= []
        self.callbacks[sym] << block
      end
  
      private
      # Calls exception handler if set (see RobustThread.exception_handler)
      def handle_exception(exc)
        if @exception_handler.is_a? Proc
          @exception_handler.call(exc)
        else
          log("Unhandled exception:\n#{exc.message} " \
              "(#{exc.class}): \n\t#{exc.backtrace.join("\n\t")}", :error)
        end
      end
  
      # Sets up the exit_handler unless exit_handler_initialized
      def init_exit_handler
        return if self.exit_handler_initialized
        self.say_goodnight = false
        at_exit do
          self.say_goodnight = true
          begin
            self.group.each do |rt|
              log "waiting on #{rt.label.inspect}" if rt.thread.alive?
              rt.thread.join
              rt.class.send :do_after_join
            end
            self.send :do_before_exit
            log "exited cleanly"
          rescue Interrupt
            log "prematurely killed by interrupt!", :error
          end
        end
        self.exit_handler_initialized = true
      end
  
      def perform_callback(sym)
        raise ArgumentError, "Cannot perform invalid callback #{sym.inspect}" unless VALID_CALLBACKS.include? sym
        return unless self.callbacks and self.callbacks[sym]
        self.callbacks[sym].reverse.each do |callback|
          callback.call
        end
      end
  
      # Performs callback, if possible
      def method_missing(sym, *args)
        if sym.to_s =~ /^do_(.*)$/
          perform_callback($1.to_sym)
        else
          raise NoMethodError, "RobustThread method_missing: #{sym.inspect}"
        end
      end
    end
  end
end
