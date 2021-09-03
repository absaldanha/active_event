# frozen_string_literal: true

module ActiveEvent
  module Broadcasters
    class TestBroadcaster
      attr_reader :sent_events

      def initialize
        @sent_events = []
      end

      def broadcast(event:, **)
        sent_events.push(event.dup)
      end

      def name
        "test"
      end

      def clear_sent_events
        @sent_events.clear
      end
    end
  end
end
