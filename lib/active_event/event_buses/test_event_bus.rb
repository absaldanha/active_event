# frozen_string_literal: true

module ActiveEvent
  module EventBuses
    class TestEventBus
      attr_reader :subscribers, :events

      def initialize
        @subscribers = []
        @events = []
      end

      def subscribe(*handlers, on: [], async: false)
        new_subs = handlers.map do |handler|
          { handler: handler, on: Array(on), async: async }
        end

        @subscribers += new_subs
      end

      def dispatch(event)
        @events << event.dup
      end

      def clear!
        subscribers.clear
        events.clear
      end

      def name
        :test
      end
    end
  end
end
