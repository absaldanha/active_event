# frozen_string_literal: true

require "test_helper"

module ActiveEvent
  class ConfigurationTest < Minitest::Test
    def test_config_with_default_event_bus
      ActiveEvent.configure do |config|
        config.event_bus = :default
      end

      assert_instance_of(
        EventBuses::DefaultEventBus,
        ActiveEvent.config.event_bus
      )
    end

    def test_config_when_test_event_bus
      ActiveEvent.configure do |config|
        config.event_bus = :test
      end

      assert_instance_of(
        EventBuses::TestEventBus,
        ActiveEvent.config.event_bus
      )
    end

    def test_config_when_invalid_event_bus
      assert_raises InvalidEventBus do
        ActiveEvent.configure do |config|
          config.event_bus = Object.new
        end
      end
    end
  end
end
