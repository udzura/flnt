require "flnt/version"
require "flnt/logger"
require "flnt/teeable_logger"
require "flnt/configuration"

module Flnt
  class << self
    # Flnt should be a Module because she is also a namespace,
    # but should behaves like a BasicObject
    ((Module.instance_methods + Module.private_instance_methods) -
      (BasicObject.instance_methods + BasicObject.private_instance_methods)).
      delete_if {|method_name| method_name.to_s =~ /([\-\[\]\/~=+*&|%<>!?])/}.
      each do |target_method|

      # Also pass the :singleton_class to avoid rspec stubbing errors
      unless [:singleton_class, :object_id, :send, :__send__].include?(target_method.to_sym)
        eval %Q(undef #{target_method})
      end
    end

    def method_missing(name, *args)
      return super if name.to_s =~ /(!|\?)$/
      initialize!
      Flnt::Logger.new(name.to_s)
    end

    def initialized?
      !! @initialized
    end

    def initialize!(force=false)
      if force or ( !initialized? and !test_mode? )
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
