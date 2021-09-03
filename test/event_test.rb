# frozen_string_literal: true

require "test_helper"
require "support/helpers/broadcaster_helper"
require "support/handlers/article_handler"
require "support/events/article_updated_event"

module ActiveEvent
  class EventTest < Minitest::Test
    include BroadcasterHelper

    def test_initialize_symbolize_payload_keys
      event = ArticleUpdatedEvent.new("foo" => 1, "bar" => 2)

      assert_equal({ foo: 1, bar: 2 }, event.payload)
    end

    def test_name_uses_underscore_class_name_without_event_by_default
      event = ArticleUpdatedEvent.new

      assert_equal("article_updated", event.name)
    end

    def test_dispatch_dispatches_self
      event = ArticleUpdatedEvent.new

      with_test_broadcaster do
        event.dispatch

        assert_equal([event], ActiveEvent.config.broadcaster.sent_events)
      end
    end

    def test_equal_with_different_class
      event = ArticleUpdatedEvent.new

      refute event == Object.new
    end

    def test_equal_with_different_payload
      event = ArticleUpdatedEvent.new(id: 123, name: "Foo")
      other = ArticleUpdatedEvent.new(id: 321, name: "Foo")

      refute event == other
    end

    def test_equal_with_same_payload
      event = ArticleUpdatedEvent.new(id: 123, name: "Foo")
      other = ArticleUpdatedEvent.new(id: 123, name: "Foo")

      assert event == other
    end
  end
end
