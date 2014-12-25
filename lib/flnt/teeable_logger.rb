require 'logger'
require 'flnt/logger'

module Flnt
  class TeeableLogger < Flnt::Logger
    def initialize(t)
      super
      @teed_loggers = []
    end
    attr_accessor :teed_loggers

    def add_teed_logger(l)
      @teed_loggers << l
    end

    def send_to_all_logger(level. arg)
      @teed_loggers.each do |l|
        l.send(level, arg)
      end
    end

    def emit!(arg, tag: nil)
      level = __get_last_tag!(tag || @tag)
      level = 'info' unless %w(debug info warn error fatal).include?(level)
      send_to_all_logger(level, arg)
      super
    end

    private
    def __get_last_tag!(tag)
      tag.split('.').last
    end
  end
end
