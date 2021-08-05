# frozen_string_literal: true

require "test_helper"
require "support/handlers/article_handler"
require "support/handlers/log_handler"
require "support/events/article_created_event"
require "support/events/article_updated_event"

module ActiveEvent
  module EventBuses
    class DefaultEventBusTest < Minitest::Test
      def test_subscribe
        event_bus = DefaultEventBus.new

        event_bus.subscribe ArticleHandler, on: ArticleCreatedEvent

        subscribers = event_bus.subscribers.to_a
        subscriber = subscribers.first

        assert_equal 1, subscribers.count
        assert_instance_of Subscribers::InlineSubscriber, subscriber
        assert_instance_of ArticleHandler, subscriber.handler
        assert_equal [ArticleCreatedEvent], subscriber.events
      end

      def test_subscribe_with_async
        event_bus = DefaultEventBus.new

        event_bus.subscribe ArticleHandler, on: ArticleCreatedEvent, async: true

        subscribers = event_bus.subscribers.to_a
        subscriber = subscribers.first

        assert_equal 1, subscribers.count
        assert_instance_of Subscribers::AsyncSubscriber, subscriber
        assert_instance_of ArticleHandler, subscriber.handler
        assert_equal [ArticleCreatedEvent], subscriber.events
      end

      def test_subscribe_with_multiple_handlers
        event_bus = DefaultEventBus.new

        event_bus.subscribe(
          ArticleHandler, LogHandler,
          on: ArticleCreatedEvent
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
        assert_instance_of ArticleHandler, subscribers.first.handler
        assert_instance_of LogHandler, subscribers.last.handler
        subscribers.each do |subscriber|
          assert_instance_of Subscribers::InlineSubscriber, subscriber
          assert_equal [ArticleCreatedEvent], subscriber.events
        end
      end

      def test_subscribe_with_multiple_events
        event_bus = DefaultEventBus.new

        event_bus.subscribe(
          ArticleHandler,
          on: [ArticleCreatedEvent, ArticleUpdatedEvent]
        )

        subscribers = event_bus.subscribers.to_a
        subscriber = subscribers.first

        assert_equal 1, subscribers.count
        assert_instance_of Subscribers::InlineSubscriber, subscriber
        assert_instance_of ArticleHandler, subscriber.handler
        assert_equal(
          [ArticleCreatedEvent, ArticleUpdatedEvent],
          subscriber.events
        )
      end

      def test_subscribe_with_multiple_handlers_and_multiple_events
        event_bus = DefaultEventBus.new

        event_bus.subscribe(
          ArticleHandler, LogHandler,
          on: [ArticleCreatedEvent, ArticleUpdatedEvent]
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
        assert_instance_of ArticleHandler, subscribers.first.handler
        assert_instance_of LogHandler, subscribers.last.handler
        subscribers.each do |subscriber|
          assert_instance_of Subscribers::InlineSubscriber, subscriber
          assert_equal(
            [ArticleCreatedEvent, ArticleUpdatedEvent],
            subscriber.events
          )
        end
      end

      def test_subscribe_with_multiple_async_handlers
        event_bus = DefaultEventBus.new

        event_bus.subscribe(
          ArticleHandler, LogHandler,
          on: ArticleCreatedEvent,
          async: true
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
        assert_instance_of ArticleHandler, subscribers.first.handler
        assert_instance_of LogHandler, subscribers.last.handler
        subscribers.each do |subscriber|
          assert_instance_of Subscribers::AsyncSubscriber, subscriber
          assert_equal [ArticleCreatedEvent], subscriber.events
        end
      end

      def test_subscribe_with_multiple_events_and_async
        event_bus = DefaultEventBus.new

        event_bus.subscribe(
          ArticleHandler,
          on: [ArticleCreatedEvent, ArticleUpdatedEvent],
          async: true
        )

        subscribers = event_bus.subscribers.to_a
        subscriber = subscribers.first

        assert_equal 1, subscribers.count
        assert_instance_of Subscribers::AsyncSubscriber, subscriber
        assert_instance_of ArticleHandler, subscriber.handler
        assert_equal(
          [ArticleCreatedEvent, ArticleUpdatedEvent],
          subscriber.events
        )
      end

      def test_subscribe_with_multiple_async_handlers_and_multiple_events
        event_bus = DefaultEventBus.new

        event_bus.subscribe(
          ArticleHandler, LogHandler,
          on: [ArticleCreatedEvent, ArticleUpdatedEvent],
          async: true
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
        assert_instance_of ArticleHandler, subscribers.first.handler
        assert_instance_of LogHandler, subscribers.last.handler
        subscribers.each do |subscriber|
          assert_instance_of Subscribers::AsyncSubscriber, subscriber
          assert_equal(
            [ArticleCreatedEvent, ArticleUpdatedEvent],
            subscriber.events
          )
        end
      end

      def test_subscribe_with_already_subscribed_handler
        event_bus = DefaultEventBus.new

        event_bus.subscribe(ArticleHandler, on: ArticleUpdatedEvent)
        event_bus.subscribe(ArticleHandler, on: ArticleCreatedEvent)

        subscribers = event_bus.subscribers.to_a

        assert_equal 1, subscribers.count
      end

      def test_subscribe_with_inline_and_async_handler
        event_bus = DefaultEventBus.new

        event_bus.subscribe(ArticleHandler, on: ArticleUpdatedEvent)
        event_bus.subscribe(
          ArticleHandler,
          on: ArticleCreatedEvent,
          async: true
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
      end

      def test_dispatch
        event_bus = DefaultEventBus.new

        event_bus.subscribe ArticleHandler, on: ArticleCreatedEvent
        event = ArticleCreatedEvent.new

        output, = capture_io do
          event_bus.dispatch(event)
        end

        assert_match "ArticleHandler: Received event!", output
      end

      def test_dispatch_with_multiple_subscribers
        event_bus = DefaultEventBus.new

        event_bus.subscribe ArticleHandler, LogHandler, on: ArticleCreatedEvent
        event = ArticleCreatedEvent.new

        output, = capture_io do
          event_bus.dispatch(event)
        end

        assert_match "ArticleHandler: Received event!", output
        assert_match "LogHandler: Received event!", output
      end

      def test_dispatch_with_no_subscribers
        event_bus = DefaultEventBus.new
        event = ArticleCreatedEvent.new

        assert_silent do
          event_bus.dispatch(event)
        end
      end

      def test_name
        event_bus = DefaultEventBus.new

        assert_equal :default, event_bus.name
      end
    end
  end
end
