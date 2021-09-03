# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "support/events/post_created_event"

module ActiveEvent
  module Broadcasters
    class TestBroadcasterTest < Minitest::Test
      def test_broadcast_stores_given_event
        broadcaster = Broadcasters::TestBroadcaster.new
        subscriber = Minitest::Mock.new
        event = PostCreatedEvent.new

        broadcaster.broadcast(event: event, to: subscriber)

        assert_equal 1, broadcaster.sent_events.size
        assert_equal PostCreatedEvent, broadcaster.sent_events.first.class
      end

      def test_clear_sent_events
        broadcaster = Broadcasters::TestBroadcaster.new
        subscriber = Minitest::Mock.new
        event = PostCreatedEvent.new

        broadcaster.broadcast(event: event, to: subscriber)

        assert_equal 1, broadcaster.sent_events.size

        broadcaster.clear_sent_events

        assert_equal 0, broadcaster.sent_events.size
      end

      def test_name_is_test
        broadcaster = Broadcasters::TestBroadcaster.new

        assert_equal "test", broadcaster.name
      end
    end
  end
end
