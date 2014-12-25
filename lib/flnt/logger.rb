require 'fluent/logger'
require 'logger'
require 'pathname'

module Flnt
  class Logger < Object
    def initialize(init_tag)
      @tag = init_tag
    end

    # method caching for common log level name
    %w(debug info warn error fatal).each do |log_level|
      define_method log_level do |arg|
        emit! args.first, tag: [@tag, log_level].join('.')
      end
    end

    def define_suffix!(suffix)
      class << self
        define_method log_level do |arg|
          emit! suffix, tag: [@tag, suffix].join('.')
        end
      end
    end

    def emit!(arg, tag: nil)
      ::Fluent::Logger.post((tag || @tag), to_info!(arg))
    end

    def tee!(logger_or_path)
      new_self = TeeableLogger.new(@tag)
      case
      when logger_or_path.respond_to?(:info)
        new_self.add_teed_logger logger_or_path
      when [::String, ::Pathname].include?(logger_or_path.class)
        l = ::Logger.new(logger_or_path)
        new_self.add_teed_logger l
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
