# frozen_string_literal: true

require "test_helper"

module ActiveEvent
  class ConfigurationTest < Minitest::Test
    def test_config_with_default_broadcaster
      ActiveEvent.configure do |config|
        config.broadcaster = :default
      end

      assert_instance_of(
        Broadcasters::DefaultBroadcaster,
        ActiveEvent.config.broadcaster
      )
    end

    def test_config_when_test_broadcaster
      ActiveEvent.configure do |config|
        config.broadcaster = :test
      end

      assert_instance_of(
        Broadcasters::TestBroadcaster,
        ActiveEvent.config.broadcaster
      )
    end

    def test_config_when_invalid_broadcaster
      assert_raises InvalidBroadcaster do
        ActiveEvent.configure do |config|
          config.broadcaster = Object.new
        end
      end
    end
  end
end
