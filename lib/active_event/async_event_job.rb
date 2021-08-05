# frozen_string_literal: true

module ActiveEvent
  class AsyncEventJob < ::ActiveJob::Base
    def perform(payload, event_class_name, handler_class)
      event = event_class_name.constantize.new(payload)
      handler = handler_class.constantize.new

      HandlerEventSender.send_event_message(handler, event)
    end
  end
end
