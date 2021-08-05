# frozen_string_literal: true

require "zeitwerk"
require "dry-configurable"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string"
require "active_job"
require "active_event/errors"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/active_event/errors.rb")
loader.setup

module ActiveEvent
  extend Dry::Configurable

  setting(:event_bus, :default) do |value|
    case value
    when String, Symbol
      EventBuses.lookup(value.to_s).new
    else
      raise InvalidEventBus, value
    end
  end

  def self.subscribe(*handlers, on: [], async: false)
    config.event_bus.subscribe(*handlers, on: on, async: async)
  end

  def self.dispatch(event)
    config.event_bus.dispatch(event)
  end
end
