# frozen_string_literal: true

module ActiveEvent
  class HandlerEventSender
    def self.send_event_message(handler, event)
      if handler.respond_to?(event.name)
        handler.public_send(event.name, event)
      elsif handler.respond_to?(:handle)
        handler.handle(event)
      else
        raise ActiveEvent::HandlerMessageError.new(handler, event)
      end
    end
  end
end
