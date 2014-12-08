require 'logger'

module Flnt
  module Teeable
    attr_accessor :teed_logger

    def emit!(arg)
      level = __get_last_tag!
      level = 'info' unless %w(debug info warn error fatal).include?(level)
      teed_logger.send(level, arg)
      super
    end
  end
end
