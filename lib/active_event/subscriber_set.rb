# frozen_string_literal: true

module ActiveEvent
  class SubscriberSet
    delegate :find, :select, :clear, :to_a, to: :@subscribers

    def initialize(subscribers = [])
      @subscribers = []
      add_all(subscribers)
    end

    def add_all(new_subscribers)
      new_subscribers.each { |new_subscriber| add(new_subscriber) }
    end

    def add(new_sub)
      existing_subscriber = find { |subscriber| subscriber == new_sub }

      if existing_subscriber
        existing_subscriber.add_events(new_sub.events)
      else
        @subscribers << new_sub
      end
    end

    def notify(event)
      subscribers_of(event).each do |subscriber|
        subscriber.notify(event)
      end
    end

    private

    def subscribers_of(event)
      select { |subscriber| subscriber.subscribed_to?(event) }
    end
  end
end
