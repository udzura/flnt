require 'fluent/logger'
require 'logger'
require 'pathname'

module Flnt
  class Logger < Object
    # Logger should behaves like a BasicObject,
    # but can skip xxx! or xxx? style methods...
    ((Object.instance_methods + Object.private_instance_methods) -
      (BasicObject.instance_methods + BasicObject.private_instance_methods)).
      delete_if {|method_name| method_name.to_s =~ /([\-\[\]\/~=+*&|%<>!?])/}.
      each do |target_method|

      # Also pass the :singleton_class to avoid rspec stubbing errors
      # And :class to avoid stack level too deep  in detecting receive ... FIXME
      unless [:class, :singleton_class, :object_id, :send, :__send__].include?(target_method.to_sym)
        eval %Q(undef #{target_method})
      end
    end

    def initialize(init_tag)
      @tag = init_tag
    end

    def method_missing(name, *args)
      return super if name.to_s =~ /(!|\?)$/

      if !args.empty?
        emit! args.first, tag: [@tag, name.to_s].join('.')
      else
        @tag << "." << name.to_s
      end

      return self
    end

    # method caching for common log level name
    %w(debug info warn error fatal).each do |log_level|
      define_method log_level do |*args|
        if !args.empty?
          emit! args.first, tag: [@tag, log_level].join('.')
        else
          @tag << "." << log_level
        end

        return self
      end
    end

    def emit!(arg, tag: nil)
      ::Fluent::Logger.post((tag || @tag), to_info!(arg))
    end

    def tee!(logger_or_path)
      new_self = TeeableLogger.new(@tag)
      case
      when logger_or_path.respond_to?(:info)
        new_self.teed_logger = logger_or_path
      when [::String, ::Pathname].include?(logger_or_path.class)
        l = ::Logger.new(logger_or_path)
        new_self.teed_logger = l
      end
      new_self
    end

    private
    def to_info!(arg)
      info = {}
      case arg
      when ::Hash
        info.merge! arg
      when ::String
        info[:message] = arg
      when ::Exception
        info[:error_class] = arg.class
        info[:message]     = arg.message
        info[:backtrace]   = arg.backtrace if arg.backtrace
      else
        info[:info] = arg
      end

      info
    end
  end
end
