# frozen_string_literal: true

require "test_helper"

module ActiveEvent
  class EventBusesTest < Minitest::Test
    def test_lookup_when_default
      assert_equal(
        EventBuses::DefaultEventBus,
        EventBuses.lookup("default")
      )
    end

    def test_lookup_when_test
      assert_equal(
        EventBuses::TestEventBus,
        EventBuses.lookup("test")
      )
    end

    def test_lookup_when_invalid
      assert_raises InvalidEventBus do
        EventBuses.lookup("foo_bar")
      end
    end
  end
end
