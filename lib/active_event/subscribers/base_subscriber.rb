# frozen_string_literal: true

module ActiveEvent
  module Subscribers
    class BaseSubscriber
      attr_reader :handler, :events

      def initialize(handler, events)
        @handler = handler
        @events = events
      end

      def notify(event)
        raise NotImplementedError
      end

      def subscribed_to?(event)
        events.any? { |subscribed_event| event.is_a?(subscribed_event) }
      end

      def async
        false
      end

      def add_events(other_events)
        @events = (events + other_events).uniq
      end

      def ==(other)
        return unless other.is_a?(BaseSubscriber)

        other.handler.instance_of?(handler.class) &&
          other.async == async
      end
    end
  end
end
