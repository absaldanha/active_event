# frozen_string_literal: true

module EventBusHelper
  def with_test_event_bus
    old_event_bus = ActiveEvent.config.event_bus.name
    ActiveEvent.config.event_bus = :test

    yield

    ActiveEvent.config.event_bus.clear!
  ensure
    ActiveEvent.config.event_bus = old_event_bus
  end

  def with_default_event_bus
    old_event_bus = ActiveEvent.config.event_bus.name
    ActiveEvent.config.event_bus = :default

    yield

    ActiveEvent.config.event_bus.clear!
  ensure
    ActiveEvent.config.event_bus = old_event_bus
  end
end
