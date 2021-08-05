# frozen_string_literal: true

module ActiveEvent
  module Subscribers
    class InlineSubscriber < BaseSubscriber
      def notify(event)
        return unless subscribed_to?(event)

        HandlerEventSender.send_event_message(handler, event)
      end
    end
  end
end
