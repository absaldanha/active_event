# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "support/events/post_created_event"

module ActiveEvent
  module Broadcasters
    class DefaultBroadcasterTest < Minitest::Test
      def test_broadcast_notifies_given_subscribers_with_given_event
        broadcaster = Broadcasters::DefaultBroadcaster.new
        subscriber = Minitest::Mock.new
        event = PostCreatedEvent.new

        subscriber.expect(:notify, nil, [event])

        broadcaster.broadcast(event: event, to: subscriber)

        subscriber.verify
      end

      def test_name_is_default
        broadcaster = Broadcasters::DefaultBroadcaster.new

        assert_equal "default", broadcaster.name
      end
    end
  end
end
