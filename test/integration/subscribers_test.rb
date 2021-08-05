# frozen_string_literal: true

require "test_helper"
require "support/events/article_created_event"
require "support/events/post_created_event"
require "support/events/post_updated_event"
require "support/handlers/article_handler"
require "support/handlers/post_handler"
require "support/handlers/log_handler"
require "support/helpers/event_bus_helper"

module ActiveEvent
  module Integration
    class SubscribersTest < Minitest::Test
      include ActiveJob::TestHelper
      include EventBusHelper

      def test_send_event_name_message_to_subscriber
        with_default_event_bus do
          ActiveEvent.subscribe(ArticleHandler, on: [ArticleCreatedEvent])

          event = ArticleCreatedEvent.new

          assert_output("ArticleHandler: Received event! article_created: {}\n") do
            event.dispatch
          end
        end
      end

      def test_send_handle_message_to_subscriber
        with_default_event_bus do
          ActiveEvent.subscribe(LogHandler, on: [ArticleCreatedEvent])

          event = ArticleCreatedEvent.new

          assert_output("LogHandler: Received event! article_created: {}\n") do
            event.dispatch
          end
        end
      end

      def test_send_event_to_all_subscribers
        with_default_event_bus do
          ActiveEvent.subscribe(
            LogHandler, ArticleHandler, on: [ArticleCreatedEvent]
          )

          expected_output = "LogHandler: Received event! article_created: {}\n" \
            "ArticleHandler: Received event! article_created: {}\n"

          event = ArticleCreatedEvent.new

          assert_output(expected_output) do
            event.dispatch
          end
        end
      end

      def test_when_no_listener_for_event
        with_default_event_bus do
          event = ArticleCreatedEvent.new

          assert_silent do
            event.dispatch
          end
        end
      end

      def test_enqueue_job_for_async_listeners
        with_default_event_bus do
          ActiveEvent.subscribe(
            ArticleHandler, on: [ArticleCreatedEvent], async: true
          )

          event = ArticleCreatedEvent.new

          event.dispatch

          assert_enqueued_with(
            job: ActiveEvent::AsyncEventJob,
            args: [{}, "ArticleCreatedEvent", "ArticleHandler"]
          )
        end
      end

      def test_inline_and_async_subscribers
        with_default_event_bus do
          ActiveEvent.subscribe(ArticleHandler, on: [ArticleCreatedEvent])
          ActiveEvent.subscribe(
            LogHandler, on: [ArticleCreatedEvent], async: true
          )

          event = ArticleCreatedEvent.new

          assert_output("ArticleHandler: Received event! article_created: {}\n") do
            event.dispatch

            assert_enqueued_with(
              job: ActiveEvent::AsyncEventJob,
              args: [{}, "ArticleCreatedEvent", "LogHandler"]
            )
          end
        end
      end

      def test_executes_job_correctly
        with_default_event_bus do
          ActiveEvent.subscribe PostHandler, on: PostCreatedEvent, async: true

          event = PostCreatedEvent.new(id: 123, title: "My first post!")

          perform_enqueued_jobs do
            output = capture_io do
              event.dispatch
            end

            assert_match "PostHandler: Received event! post_created", output.first
            assert_match(/{:id=>123, :title=>"My first post!"}/, output.first)
          end
        end
      end

      def test_handles_all_events_of_an_type
        with_default_event_bus do
          ActiveEvent.subscribe LogHandler, on: TestEvent

          post_created_event = PostCreatedEvent.new
          article_created_event = ArticleCreatedEvent.new
          post_updated_event = PostUpdatedEvent.new

          output = capture_io do
            post_created_event.dispatch
            article_created_event.dispatch
            post_updated_event.dispatch
          end

          assert_match "Received event! post_created", output.first
          assert_match "Received event! article_created", output.first
          assert_match "Received event! post_updated", output.first
        end
      end
    end
  end
end
