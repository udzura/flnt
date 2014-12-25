require "flnt/version"
require "flnt/logger"
require "flnt/teeable_logger"
require "flnt/configuration"

module Flnt
  class << self
    def initialized?
      !! @initialized
    end

    def initialize!
      if !initialized? and !test_mode?
        @initialized = true
        Fluent::Logger::FluentLogger.open(*Flnt::Configuration())
      end
    end

    def tag!(tag)
      initialize!
      Flnt::Logger.new(tag.to_s)
    end

    # This is useful for testing
    def test_mode!
      @test_mode = true
      # Switch the default logger
      ::Fluent::Logger.open(::Fluent::Logger::TestLogger)
    end

    def test_mode?
      @test_mode || false
    end
  end
end
