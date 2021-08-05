# frozen_string_literal: true

require "test_helper"
require "support/events/post_updated_event"
require "support/handlers/post_handler"

module ActiveEvent
  module Subscribers
    class InlineSubscriberTest < Minitest::Test
      def test_notify_skips_event_if_not_subscribed
        event = PostUpdatedEvent.new
        subscriber = Subscribers::InlineSubscriber.new(PostHandler.new, [])

        subscriber.notify(event)

        assert_silent do
          subscriber.notify(event)
        end
      end

      def test_notify_sends_message_to_handler
        event = PostUpdatedEvent.new
        subscriber = Subscribers::InlineSubscriber.new(
          PostHandler.new,
          [PostUpdatedEvent]
        )

        assert_output("PostHandler: Received event! post_updated: {}\n") do
          subscriber.notify(event)
        end
      end

      def test_async
        subscriber = Subscribers::InlineSubscriber.new(
          PostHandler.new,
          [PostUpdatedEvent]
        )

        refute subscriber.async
      end
    end
  end
end
