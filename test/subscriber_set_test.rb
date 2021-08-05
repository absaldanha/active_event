# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "support/events/article_updated_event"
require "support/events/article_created_event"
require "support/handlers/log_handler"
require "support/handlers/article_handler"
require "support/handlers/post_handler"

module ActiveEvent
  class SubscriberSetTest < Minitest::Test
    def test_notify_notifies_only_correct_subscribers
      event = ArticleUpdatedEvent.new

      log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleUpdatedEvent]
      )
      article_subscriber = Subscribers.build(
        handler: ArticleHandler,
        events: [ArticleUpdatedEvent]
      )
      post_subscriber = Subscribers.build(
        handler: PostHandler,
        events: []
      )

      subscriber_set = SubscriberSet.new(
        [log_subscriber, post_subscriber, article_subscriber]
      )

      output, = capture_io do
        subscriber_set.notify(event)
      end

      assert_match "LogHandler: Received event!", output
      assert_match "ArticleHandler: Received event!", output
    end

    def test_notify_with_no_subscriber
      subscriber_set = SubscriberSet.new
      event = ArticleUpdatedEvent.new

      assert_silent do
        subscriber_set.notify(event)
      end
    end

    def test_add
      subscriber_set = SubscriberSet.new

      log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleUpdatedEvent]
      )

      subscriber_set.add(log_subscriber)

      assert_equal [log_subscriber], subscriber_set.to_a
    end

    def test_add_when_subscriber_aleready_exists
      subscriber_set = SubscriberSet.new

      log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleUpdatedEvent]
      )

      other_log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleCreatedEvent]
      )

      subscriber_set.add(log_subscriber)
      subscriber_set.add(other_log_subscriber)

      assert_equal [log_subscriber], subscriber_set.to_a
      assert_equal(
        [ArticleUpdatedEvent, ArticleCreatedEvent],
        log_subscriber.events
      )
    end

    def test_add_all
      subscriber_set = SubscriberSet.new

      log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleUpdatedEvent]
      )

      article_subscriber = Subscribers.build(
        handler: ArticleHandler,
        events: [ArticleUpdatedEvent]
      )

      subscriber_set.add_all([log_subscriber, article_subscriber])

      assert_equal(
        [log_subscriber, article_subscriber],
        subscriber_set.to_a
      )
    end

    def test_add_all_when_any_subscriber_already_exists
      subscriber_set = SubscriberSet.new

      log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleUpdatedEvent],
        async: true
      )

      other_log_subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleCreatedEvent],
        async: true
      )

      article_subscriber = Subscribers.build(
        handler: ArticleHandler,
        events: [ArticleUpdatedEvent]
      )

      other_article_subscriber = Subscribers.build(
        handler: ArticleHandler,
        events: [ArticleCreatedEvent]
      )

      post_subscriber = Subscribers.build(
        handler: PostHandler,
        events: []
      )

      other_post_subscriber = Subscribers.build(
        handler: PostHandler,
        events: [],
        async: true
      )

      subscriber_set.add(log_subscriber)
      subscriber_set.add(article_subscriber)
      subscriber_set.add(post_subscriber)

      subscriber_set.add_all(
        [other_log_subscriber, other_article_subscriber, other_post_subscriber]
      )

      assert_equal(
        [
          log_subscriber,
          article_subscriber,
          post_subscriber,
          other_post_subscriber
        ],
        subscriber_set.to_a
      )

      assert_equal(
        [ArticleUpdatedEvent, ArticleCreatedEvent],
        log_subscriber.events
      )
      assert_equal(
        [ArticleUpdatedEvent, ArticleCreatedEvent],
        article_subscriber.events
      )
      assert_equal([], post_subscriber.events)
    end
  end
end
