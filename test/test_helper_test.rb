# frozen_string_literal: true

require "test_helper"
require "active_support/testing/assertions"
require "support/handlers/post_handler"
require "support/events/post_created_event"
require "support/events/post_updated_event"
require "support/events/article_created_event"

module ActiveEvent
  class TestHelperTest < Minitest::Test
    include ActiveEvent::TestHelper
    include ActiveSupport::Testing::Assertions

    def test_assert_sent_events
      event = PostCreatedEvent.new

      assert_nothing_raised do
        assert_sent_events 1 do
          event.dispatch
        end
      end
    end

    def test_repeated_assert_sent_events
      created_event = PostCreatedEvent.new
      updated_event = PostUpdatedEvent.new

      assert_nothing_raised do
        assert_sent_events 1 do
          created_event.dispatch
        end
      end

      assert_nothing_raised do
        assert_sent_events 2 do
          created_event.dispatch
          updated_event.dispatch
        end
      end
    end

    def test_assert_sent_events_without_a_block
      created_event = PostCreatedEvent.new
      updated_event = PostUpdatedEvent.new

      assert_nothing_raised do
        created_event.dispatch

        assert_sent_events 1

        updated_event.dispatch

        assert_sent_events 2
      end
    end

    def test_assert_sent_events_message
      event = PostUpdatedEvent.new

      error = assert_raises Minitest::Assertion do
        assert_sent_events 2 do
          event.dispatch
        end
      end

      assert_match "Expected: 2", error.message
      assert_match "Actual: 1", error.message
      assert_match "2 events expected, but got 1", error.message
    end

    def test_assert_sent_events_with_a_block_and_without_a_block
      created_event = PostCreatedEvent.new
      updated_event = PostUpdatedEvent.new

      assert_nothing_raised do
        created_event.dispatch

        assert_sent_events 1

        assert_sent_events 1 do
          updated_event.dispatch
        end
      end
    end

    def test_assert_sent_events_with_more_than_expected
      event = PostCreatedEvent.new

      error = assert_raises Minitest::Assertion do
        assert_sent_events 1 do
          event.dispatch
          event.dispatch
        end
      end

      assert_match "1 events expected, but got 2", error.message
    end

    def test_assert_sent_events_with_less_than_expected
      error = assert_raises Minitest::Assertion do
        assert_sent_events 1
      end

      assert_match "1 events expected, but got 0", error.message
    end

    def test_assert_sent_events_with_only_option
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_sent_events 1, only: PostUpdatedEvent do
          post_created_event.dispatch
          post_updated_event.dispatch
          article_created_event.dispatch
        end
      end
    end

    def test_assert_sent_events_with_only_option_as_array
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_sent_events 2, only: [PostUpdatedEvent, ArticleCreatedEvent] do
          post_created_event.dispatch
          post_updated_event.dispatch
          article_created_event.dispatch
        end
      end
    end

    def test_assert_sent_events_with_except_option
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_sent_events 2, except: PostUpdatedEvent do
          post_created_event.dispatch
          post_updated_event.dispatch
          article_created_event.dispatch
        end
      end
    end

    def test_assert_sent_events_with_except_option_as_array
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_sent_events 1, except: [PostCreatedEvent, PostUpdatedEvent] do
          post_created_event.dispatch
          post_updated_event.dispatch
          article_created_event.dispatch
        end
      end
    end

    def test_assert_sent_events_with_only_and_except_options
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new
      article_created_event = ArticleCreatedEvent.new

      error = assert_raises ArgumentError do
        assert_sent_events 1, only: PostUpdatedEvent, except: PostCreatedEvent do
          post_created_event.dispatch
          post_updated_event.dispatch
          article_created_event.dispatch
        end
      end

      assert_match "`:only` and `:except`", error.message
    end

    def test_assert_no_sent_events
      assert_nothing_raised do
        assert_no_sent_events do
          PostCreatedEvent.new
        end
      end
    end

    def test_assert_no_sent_events_without_a_block
      assert_nothing_raised do
        assert_no_sent_events
      end
    end

    def test_assert_no_sent_events_with_and_without_a_block
      assert_nothing_raised do
        post_created_event = PostCreatedEvent.new
        post_created_event.dispatch

        assert_no_sent_events do
          PostUpdatedEvent.new
        end
      end
    end

    def test_assert_no_sent_events_message
      post_created_event = PostCreatedEvent.new

      error = assert_raises Minitest::Assertion do
        assert_no_sent_events do
          post_created_event.dispatch
        end
      end

      assert_match "Expected: 0", error.message
      assert_match "Actual: 1", error.message
      assert_match "0 events expected, but got 1", error.message
    end

    def test_assert_no_sent_events_with_only_option
      post_created_event = PostCreatedEvent.new
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_no_sent_events only: PostUpdatedEvent do
          post_created_event.dispatch
          article_created_event.dispatch
        end
      end
    end

    def test_assert_no_sent_events_with_only_option_as_array
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_no_sent_events only: [PostUpdatedEvent, PostCreatedEvent] do
          article_created_event.dispatch
        end
      end
    end

    def test_assert_no_sent_events_with_except_option
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_no_sent_events except: ArticleCreatedEvent do
          article_created_event.dispatch
        end
      end
    end

    def test_assert_no_sent_events_with_except_option_as_array
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new

      assert_nothing_raised do
        assert_no_sent_events except: [PostUpdatedEvent, PostCreatedEvent] do
          post_created_event.dispatch
          post_updated_event.dispatch
        end
      end
    end

    def test_assert_no_sent_events_with_only_and_except_option
      error = assert_raises ArgumentError do
        assert_no_sent_events only: PostCreatedEvent, except: PostUpdatedEvent do
          post_created_event = PostCreatedEvent.new
          post_created_event.dispatch
        end
      end

      assert_match "`:only` and `:except`", error.message
    end

    def test_assert_sent_event_with
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        assert_sent_event_with event: ArticleCreatedEvent do
          article_created_event.dispatch
        end
      end
    end

    def test_assert_sent_event_with_without_a_block
      article_created_event = ArticleCreatedEvent.new

      assert_nothing_raised do
        article_created_event.dispatch

        assert_sent_event_with event: ArticleCreatedEvent
      end
    end

    def test_assert_sent_event_with_message
      post_created_event = PostCreatedEvent.new
      post_updated_event = PostUpdatedEvent.new

      error = assert_raises Minitest::Assertion do
        assert_sent_event_with event: ArticleCreatedEvent do
          post_created_event.dispatch
          post_updated_event.dispatch
        end
      end

      assert_match "No event found for ArticleCreatedEvent", error.message
    end

    def test_assert_sent_event_with_passing_payload
      post_created_event = PostCreatedEvent.new(foo: "bar", fuz: "buz")
      post_updated_event = PostUpdatedEvent.new

      assert_nothing_raised do
        assert_sent_event_with event: PostCreatedEvent, payload: { foo: "bar", fuz: "buz" } do
          post_created_event.dispatch
          post_updated_event.dispatch
        end
      end
    end

    def test_assert_sent_event_with_passing_payload_message
      with_args_event = ArticleCreatedEvent.new(some: "args")
      without_args_event = ArticleCreatedEvent.new

      error = assert_raises Minitest::Assertion do
        assert_sent_event_with event: ArticleCreatedEvent, payload: { foo: "bar" } do
          with_args_event.dispatch
          without_args_event.dispatch
        end
      end

      assert_match(
        /No event found for {:event=>ArticleCreatedEvent, :payload=>{:foo=>"bar"}}/,
        error.message
      )
      assert_match "Potential matches", error.message
      assert_match(
        "{:event=>ArticleCreatedEvent, :payload=>{:some=>\"args\"}}",
        error.message
      )
      assert_match "{:event=>ArticleCreatedEvent, :payload=>{}}", error.message
    end

    def test_assert_sent_event_with_passing_only_payload
      event = PostCreatedEvent.new(first_arg: 1, second_arg: 2)

      assert_nothing_raised do
        assert_sent_event_with payload: { first_arg: 1, second_arg: 2 } do
          event.dispatch
        end
      end
    end

    def test_with_inline_events_send_events_to_real_handlers
      ActiveEvent.subscribe(PostHandler, on: PostCreatedEvent)

      event = PostCreatedEvent.new

      assert_nothing_raised do
        with_inline_events do
          out, = capture_io do
            event.dispatch
          end

          assert_match(
            "PostHandler: Received event! post_created: {}\n",
            out
          )
        end
      end
    end

    def test_with_inline_events_send_async_events_to_real_handlers
      ActiveEvent.subscribe(PostHandler, on: PostCreatedEvent, async: true)

      event = PostCreatedEvent.new

      assert_nothing_raised do
        with_inline_events do
          out, = capture_io do
            event.dispatch
          end

          assert_match(
            "PostHandler: Received event! post_created: {}\n",
            out
          )
        end
      end
    end
  end
end
