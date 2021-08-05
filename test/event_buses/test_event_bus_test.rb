# frozen_string_literal: true

require "test_helper"
require "support/handlers/article_handler"
require "support/handlers/log_handler"
require "support/events/article_created_event"
require "support/events/post_updated_event"

module ActiveEvent
  module EventBuses
    class TestEventBusTest < Minitest::Test
      def test_subscribe
        event_bus = TestEventBus.new

        event_bus.subscribe ArticleHandler, on: ArticleCreatedEvent

        subscribers = event_bus.subscribers.to_a

        assert_equal 1, subscribers.count
        assert_equal(
          [
            {
              handler: ArticleHandler,
              on: [ArticleCreatedEvent],
              async: false
            }
          ],
          subscribers
        )
      end

      def test_subscribe_with_async
        event_bus = TestEventBus.new

        event_bus.subscribe ArticleHandler, on: ArticleCreatedEvent, async: true

        subscribers = event_bus.subscribers.to_a

        assert_equal 1, subscribers.count
        assert_equal(
          [
            {
              handler: ArticleHandler,
              on: [ArticleCreatedEvent],
              async: true
            }
          ],
          subscribers
        )
      end

      def test_subscribe_with_multiple_handlers
        event_bus = TestEventBus.new

        event_bus.subscribe ArticleHandler, LogHandler, on: ArticleCreatedEvent

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
        assert_equal(
          [
            {
              handler: ArticleHandler,
              on: [ArticleCreatedEvent],
              async: false
            },
            {
              handler: LogHandler,
              on: [ArticleCreatedEvent],
              async: false
            }
          ],
          subscribers
        )
      end

      def test_subscribe_with_multiple_events
        event_bus = TestEventBus.new

        event_bus.subscribe(
          LogHandler,
          on: [ArticleCreatedEvent, PostUpdatedEvent]
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 1, subscribers.count
        assert_equal(
          [
            {
              handler: LogHandler,
              on: [ArticleCreatedEvent, PostUpdatedEvent],
              async: false
            }
          ],
          subscribers
        )
      end

      def test_subscribe_with_multiple_handlers_and_multiple_events
        event_bus = TestEventBus.new

        event_bus.subscribe(
          LogHandler, ArticleHandler,
          on: [ArticleCreatedEvent, PostUpdatedEvent]
        )

        subscribers = event_bus.subscribers.to_a

        assert_equal 2, subscribers.count
        assert_equal(
          [
            {
              handler: LogHandler,
              on: [ArticleCreatedEvent, PostUpdatedEvent],
              async: false
            },
            {
              handler: ArticleHandler,
              on: [ArticleCreatedEvent, PostUpdatedEvent],
              async: false
            }
          ],
          subscribers
        )
      end

      def test_dispatch
        event_bus = TestEventBus.new

        article_event = ArticleCreatedEvent.new
        post_event = PostUpdatedEvent.new

        event_bus.dispatch(article_event)
        event_bus.dispatch(post_event)

        assert_equal([article_event, post_event], event_bus.events)
      end

      def test_name
        event_bus = TestEventBus.new

        assert_equal :test, event_bus.name
      end
    end
  end
end
