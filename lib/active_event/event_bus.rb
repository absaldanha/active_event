# frozen_string_literal: true

module ActiveEvent
  class EventBus
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
      broadcaster.broadcast(event: event, to: subscribers)
    end

    def broadcaster
      ActiveEvent.config.broadcaster
    end

    def clear!
      subscribers.clear
    end
  end
end
