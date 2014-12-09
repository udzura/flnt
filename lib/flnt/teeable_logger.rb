require 'logger'
require 'flnt/logger'

module Flnt
  class TeeableLogger < Flnt::Logger
    attr_accessor :teed_logger

    def emit!(arg, tag: nil)
      level = __get_last_tag!(tag || @tag)
      level = 'info' unless %w(debug info warn error fatal).include?(level)
      teed_logger.send(level, arg)
      super
    end

    private
    def __get_last_tag!(tag)
      tag.split('.').last
    end
  end
end
