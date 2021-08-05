# frozen_string_literal: true

require "test_helper"
require "support/handlers/article_handler"
require "support/handlers/log_handler"
require "support/events/article_created_event"

module ActiveEvent
  class SubscribersTest < Minitest::Test
    def test_build_when_async
      subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleCreatedEvent],
        async: true
      )

      assert_instance_of(Subscribers::AsyncSubscriber, subscriber)
      assert_instance_of(LogHandler, subscriber.handler)
      assert_equal([ArticleCreatedEvent], subscriber.events)
    end

    def test_build_when_not_async
      subscriber = Subscribers.build(
        handler: LogHandler,
        events: [ArticleCreatedEvent]
      )

      assert_instance_of(Subscribers::InlineSubscriber, subscriber)
      assert_instance_of(LogHandler, subscriber.handler)
      assert_equal([ArticleCreatedEvent], subscriber.events)
    end

    def test_build_all_when_async
      subs = Subscribers.build_all(
        handlers: [ArticleHandler, LogHandler],
        events: [ArticleCreatedEvent],
        async: true
      )

      assert_equal 2, subs.count

      subs.each do |sub|
        assert_instance_of(Subscribers::AsyncSubscriber, sub)
        assert_equal([ArticleCreatedEvent], sub.events)
      end

      assert_instance_of(ArticleHandler, subs.first.handler)
      assert_instance_of(LogHandler, subs.last.handler)
    end

    def test_build_all_when_not_async
      subs = Subscribers.build_all(
        handlers: [ArticleHandler, LogHandler],
        events: [ArticleCreatedEvent]
      )

      assert_equal 2, subs.count

      subs.each do |sub|
        assert_instance_of(Subscribers::InlineSubscriber, sub)
        assert_equal([ArticleCreatedEvent], sub.events)
      end

      assert_instance_of(ArticleHandler, subs.first.handler)
      assert_instance_of(LogHandler, subs.last.handler)
    end
  end
end
