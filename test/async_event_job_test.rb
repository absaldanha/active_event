# frozen_string_literal: true

require "test_helper"
require "support/events/post_created_event"
require "support/handlers/post_handler"

module ActiveEvent
  class AsyncEventJobTest < Minitest::Test
    def test_perform
      out = capture_io do
        AsyncEventJob.perform_now(
          { some: "payload" },
          "PostCreatedEvent",
          "PostHandler"
        )
      end

      assert_match "PostHandler: Received event! post_created", out.first
      assert_match(/{:some=>"payload"}/, out.first)
    end
  end
end
