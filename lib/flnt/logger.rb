require 'fluent/logger'
require 'flnt/teeable'
require 'logger'

module Flnt
  class Logger < BasicObject
    def initialize(init_tag)
      @tag = init_tag
    end

    def method_missing(name, *args)
      return super if name.to_s =~ /(!|\?)$/

      @tag = [@tag, name.to_s].join('.')
      unless args.empty?
        emit! args.first
      end

      return self
    end

    # method caching for common log level name
    %w(debug info warn error fatal).each do |log_level|
      define_method log_level do |*args|
        @tag << "." << log_level.to_s
        unless args.empty?
          emit! args.first
        end

        return self
      end
    end

    def __get_last_tag!
      @tag.split('.').last
    end

    def emit!(arg)
      ::Fluent::Logger.post @tag, to_info!(arg)
    end

    def tee!(logger_or_path)
      extend Teeable
      case
      when logger_or_path.respond_to?(:info)
        self.teed_logger = logger_or_path
      when
        l = ::Logger.new(logger_or_path)
        self.teed_logger = l
      end
      self
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
