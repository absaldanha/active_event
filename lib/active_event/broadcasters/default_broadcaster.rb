# frozen_string_literal: true

module ActiveEvent
  module Broadcasters
    class DefaultBroadcaster
      def broadcast(event:, to:)
        Array(to).each { |subscriber| subscriber.notify(event) }
      end

      def name
        "default"
      end
    end
  end
end
