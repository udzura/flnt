require 'fluent/logger'

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

    def emit!(arg)
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
      ::Fluent::Logger.post @tag, info
    end
  end
end
