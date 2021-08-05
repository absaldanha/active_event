# frozen_string_literal: true

module ActiveEvent
  module Subscribers
    class AsyncSubscriber < BaseSubscriber
      def notify(event)
        return unless subscribed_to?(event)

        AsyncEventJob.perform_later(
          event.payload,
          event.class.name,
          handler.class.name
        )
      end

      def async
        true
      end
    end
  end
end
