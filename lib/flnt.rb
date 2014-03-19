require "flnt/version"
require "flnt/logger"
require "flnt/configuration"

module Flnt
  class << self
    # Flnt should be a Module because she is also a namespace,
    # but should behaves like a BasicObject
    ((Module.instance_methods + Module.private_instance_methods) -
      (BasicObject.instance_methods + BasicObject.private_instance_methods)).
      delete_if {|method_name| method_name.to_s =~ /([\-\[\]\/~=+*&|%<>!?])/}.
      each do |target_method|
      if target_method.to_sym != :object_id
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

    def initialize!
      unless initialized?
        @initialized = true
        Fluent::Logger::FluentLogger.open(*Flnt::Configuration())
      end
    end
  end
end
