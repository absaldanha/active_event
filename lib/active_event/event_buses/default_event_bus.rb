# frozen_string_literal: true

module ActiveEvent
  module EventBuses
    class DefaultEventBus
      attr_reader :subscribers

      def initialize
        @subscribers = SubscriberSet.new
      end

      def subscribe(*handlers, on:, async: false)
        new_subs = Subscribers.build_all(
          handlers: handlers,
          events: Array(on),
          async: async
        )

        subscribers.add_all(new_subs)
      end

      def dispatch(event)
        subscribers.notify(event)
      end

      def clear!
        subscribers.clear
      end

      def name
        :default
      end
    end
  end
end
