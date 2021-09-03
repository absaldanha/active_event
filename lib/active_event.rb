# frozen_string_literal: true

require "zeitwerk"
require "dry-configurable"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/string"
require "active_job"
require "active_event/errors"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/active_event/errors.rb")
loader.setup

module ActiveEvent
  extend Dry::Configurable

  mattr_reader :event_bus, instance_accessor: false, default: EventBus.new

  setting(:broadcaster, :default) do |value|
    case value
    when String, Symbol
      Broadcasters.lookup(value).new
    else
      raise InvalidBroadcaster, value
    end
  end

  def self.subscribe(*handlers, on: [], async: false)
    event_bus.subscribe(*handlers, on: on, async: async)
  end

  def self.dispatch(event)
    event_bus.dispatch(event)
  end
end
