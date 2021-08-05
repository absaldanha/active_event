# frozen_string_literal: true

require "test_helper"
require "support/handlers/article_handler"
require "support/events/article_created_event"
require "support/events/article_updated_event"

module ActiveEvent
  module Subscribers
    class BaseSubscriberTest < Minitest::Test
      def test_notify_must_be_implemented_by_subclasses
        subscriber = Subscribers::BaseSubscriber.new(Object.new, [])

        assert_raises(NotImplementedError) do
          subscriber.notify(Object.new)
        end
      end

      def test_subscribed_to_matches_event_when_subscribed
        event = ArticleCreatedEvent.new
        subscriber = Subscribers::BaseSubscriber.new(
          Object.new,
          [ArticleCreatedEvent]
        )

        assert subscriber.subscribed_to?(event)
      end

      def test_subscribed_to_doesnt_match_event_when_not_subscribed
        event = ArticleCreatedEvent.new
        subscriber = Subscribers::BaseSubscriber.new(
          Object.new,
          [ArticleUpdatedEvent]
        )

        refute subscriber.subscribed_to?(event)
      end

      def test_subscribed_to_matches_event_ancestors
        event = ArticleUpdatedEvent.new
        subscriber = Subscribers::BaseSubscriber.new(Object.new, [TestEvent])

        assert subscriber.subscribed_to?(event)
      end

      def test_equal_other_when_not_a_subscriber
        subscriber = Subscribers::BaseSubscriber.new(
          Object.new,
          [ArticleUpdatedEvent]
        )

        refute subscriber == Object.new
      end

      def test_equal_other_when_not_same_handler_class
        subscriber = Subscribers::BaseSubscriber.new(
          ArticleHandler.new,
          [ArticleUpdatedEvent]
        )

        other = Subscribers::BaseSubscriber.new(
          Object.new,
          [ArticleUpdatedEvent]
        )

        refute subscriber == other
      end

      def test_equal_other_when_not_same_sync_value
        subscriber = Subscribers::InlineSubscriber.new(
          ArticleHandler.new,
          [ArticleUpdatedEvent]
        )

        other = Subscribers::AsyncSubscriber.new(
          Object.new,
          [ArticleUpdatedEvent]
        )

        refute subscriber == other
      end

      def test_equal_other_when_equal
        subscriber = Subscribers::InlineSubscriber.new(
          ArticleHandler.new,
          [ArticleUpdatedEvent]
        )

        other = Subscribers::InlineSubscriber.new(
          ArticleHandler.new,
          [ArticleUpdatedEvent, ArticleCreatedEvent]
        )

        assert subscriber == other
      end
    end
  end
end
