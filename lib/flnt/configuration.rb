require 'flnt'

module Flnt
  module Configuration
    class << self
      def host
        @host ||= 'localhost'
      end

      def port
        @port ||= 24224
      end
      attr_writer   :host, :port
      attr_accessor :prefix

      def to_fluentd_config
        [
          prefix,
          {
            host: host,
            port: port,
          }
        ]
      end

      def configure &b
        b.call(self)
        ::Flnt.initialize!(true)
      end
    end
  end

  def self.Configuration
    Configuration.to_fluentd_config
  end
end
