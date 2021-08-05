# frozen_string_literal: true

module ActiveEvent
  module Subscribers
    def self.build_all(handlers:, events:, async: false)
      handlers.map do |handler|
        build(handler: handler, events: events, async: async)
      end
    end

    def self.build(handler:, events:, async: false)
      handler_object = handler.new

      return AsyncSubscriber.new(handler_object, events) if async

      InlineSubscriber.new(handler_object, events)
    end
  end
end
