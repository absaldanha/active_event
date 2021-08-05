# frozen_string_literal: true

require "test_helper"
require "support/events/post_created_event"
require "support/handlers/post_handler"

module ActiveEvent
  module Subscribers
    class AsyncSubscriberTest < Minitest::Test
      include ActiveJob::TestHelper

      def test_notify_skips_event_if_not_subscribed
        event = PostCreatedEvent.new
        subscriber = Subscribers::AsyncSubscriber.new(PostHandler.new, [])

        assert_no_enqueued_jobs do
          subscriber.notify(event)
        end
      end

      def test_notify_enqueues_job
        event = PostCreatedEvent.new(some: "payload")
        subscriber = Subscribers::AsyncSubscriber.new(
          PostHandler.new,
          [PostCreatedEvent]
        )

        subscriber.notify(event)

        assert_enqueued_with(
          job: ActiveEvent::AsyncEventJob,
          args: [{ some: "payload" }, "PostCreatedEvent", "PostHandler"]
        )
      end

      def test_async
        subscriber = Subscribers::AsyncSubscriber.new(
          PostHandler.new,
          [PostCreatedEvent]
        )

        assert subscriber.async
      end
    end
  end
end
