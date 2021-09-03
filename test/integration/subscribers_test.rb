# frozen_string_literal: true

require "test_helper"
require "support/helpers/broadcaster_helper"
require "support/events/article_created_event"
require "support/events/post_created_event"
require "support/events/post_updated_event"
require "support/handlers/article_handler"
require "support/handlers/post_handler"
require "support/handlers/log_handler"

module ActiveEvent
  module Integration
    class SubscribersTest < Minitest::Test
      include ActiveJob::TestHelper
      include BroadcasterHelper

      def test_send_event_name_message_to_subscriber
        ActiveEvent.subscribe(ArticleHandler, on: [ArticleCreatedEvent])

        event = ArticleCreatedEvent.new

        with_default_broadcaster do
          out, = capture_io do
            event.dispatch
          end

          assert_match(
            "ArticleHandler: Received event! article_created: {}\n",
            out
          )
        end
      end

      def test_send_handle_message_to_subscriber
        ActiveEvent.subscribe(LogHandler, on: [ArticleCreatedEvent])

        event = ArticleCreatedEvent.new

        with_default_broadcaster do
          assert_output("LogHandler: Received event! article_created: {}\n") do
            event.dispatch
          end
        end
      end

      def test_send_event_to_all_subscribers
        ActiveEvent.subscribe(
          LogHandler, ArticleHandler, on: [ArticleCreatedEvent]
        )

        expected_output = "LogHandler: Received event! article_created: {}\n" \
          "ArticleHandler: Received event! article_created: {}\n"

        event = ArticleCreatedEvent.new

        with_default_broadcaster do
          assert_output(expected_output) do
            event.dispatch
          end
        end
      end

      def test_when_no_listener_for_event
        event = ArticleCreatedEvent.new

        with_default_broadcaster do
          assert_silent do
            event.dispatch
          end
        end
      end

      def test_enqueue_job_for_async_listeners
        ActiveEvent.subscribe(
          ArticleHandler, on: [ArticleCreatedEvent], async: true
        )

        event = ArticleCreatedEvent.new

        with_default_broadcaster do
          event.dispatch

          assert_enqueued_with(
            job: ActiveEvent::AsyncEventJob,
            args: [{}, "ArticleCreatedEvent", "ArticleHandler"]
          )
        end
      end

      def test_inline_and_async_subscribers
        ActiveEvent.subscribe(ArticleHandler, on: [ArticleCreatedEvent])
        ActiveEvent.subscribe(
          LogHandler, on: [ArticleCreatedEvent], async: true
        )

        event = ArticleCreatedEvent.new

        with_default_broadcaster do
          out, = capture_io do
            event.dispatch

            assert_enqueued_with(
              job: ActiveEvent::AsyncEventJob,
              args: [{}, "ArticleCreatedEvent", "LogHandler"]
            )
          end

          assert_match(
            "ArticleHandler: Received event! article_created: {}\n",
            out
          )
        end
      end

      def test_executes_job_correctly
        ActiveEvent.subscribe PostHandler, on: PostCreatedEvent, async: true

        event = PostCreatedEvent.new(id: 123, title: "My first post!")

        perform_enqueued_jobs do
          with_default_broadcaster do
            output = capture_io do
              event.dispatch
            end

            assert_match(
              "PostHandler: Received event! post_created",
              output.first
            )
            assert_match(/{:id=>123, :title=>"My first post!"}/, output.first)
          end
        end
      end

      def test_handles_all_events_of_an_type
        ActiveEvent.subscribe LogHandler, on: TestEvent

        post_created_event = PostCreatedEvent.new
        article_created_event = ArticleCreatedEvent.new
        post_updated_event = PostUpdatedEvent.new

        with_default_broadcaster do
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
