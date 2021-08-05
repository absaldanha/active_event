# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "support/events/post_created_event"

module ActiveEvent
  class HandlerEventSenderTest < Minitest::Test
    def test_send_event_message_with_event_name
      event = PostCreatedEvent.new
      handler = Minitest::Mock.new

      handler.expect(:post_created, nil, [event])

      HandlerEventSender.send_event_message(handler, event)

      handler.verify
    end

    def test_send_event_message_with_handle_message
      event = PostCreatedEvent.new
      handler = Minitest::Mock.new

      handler.expect(:handle, nil, [event])

      HandlerEventSender.send_event_message(handler, event)

      handler.verify
    end

    def test_send_event_message_when_handler_doesnt_respond_to_messages
      event = PostCreatedEvent.new
      handler = Minitest::Mock.new

      assert_raises ActiveEvent::HandlerMessageError do
        HandlerEventSender.send_event_message(handler, event)
      end
    end
  end
end
