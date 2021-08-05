# frozen_string_literal: true

require "active_support/testing/assertions"

module ActiveEvent
  module TestHelper
    include ActiveSupport::Testing::Assertions

    def before_setup
      ActiveEvent.config.event_bus = :test
      ActiveEvent.config.event_bus.clear!

      super
    end

    def after_teardown
      super

      ActiveEvent.config.event_bus.clear!
      ActiveEvent.config.event_bus = :default
    end

    def assert_sent_events(number, only: nil, except: nil, &block)
      actual_number = events_with(only: only, except: except, &block).count

      assert_equal(
        number,
        actual_number,
        "#{number} events expected, but got #{actual_number}"
      )
    end

    def assert_sent_event_with(event: nil, payload: nil, &block)
      potential_events = events_with(only: event, &block)

      if payload
        find_with_payload(potential_events, payload, event)
      else
        assert potential_events.any?, "No event found for #{event}"
      end
    end

    def assert_no_sent_events(only: nil, except: nil, &block)
      assert_sent_events 0, only: only, except: except, &block
    end

    def received_events
      ActiveEvent.config.event_bus.events
    end

    private

    def find_events_with(only: nil, except: nil)
      if only && except
        raise ArgumentError, "Cannot specify both `:only` and `:except`options"
      end

      if only
        array = Array(only)
        received_events.select { |event| array.include?(event.class) }
      elsif except
        array = Array(except)
        received_events.reject { |event| array.include?(event.class) }
      else
        received_events.dup
      end
    end

    def events_with(only: nil, except: nil, &block)
      if block
        original_events = find_events_with(only: only, except: except)

        assert_nothing_raised(&block)

        new_events = find_events_with(only: only, except: except)

        new_events - original_events
      else
        find_events_with(only: only, except: except)
      end
    end

    def find_with_payload(potential_events, payload, event)
      not_found = "No event found for #{{ event: event, payload: payload }}"

      assert false, not_found if potential_events.empty?

      matching_event = potential_events.find do |potential_event|
        potential_event.payload == payload
      end

      events_hash = potential_events.map do |potential_event|
        { event: potential_event.class, payload: potential_event.payload }
      end

      potentials_message = "\n\nPotential matches:\n#{events_hash.join("\n")}"

      assert matching_event, not_found + potentials_message
    end
  end
end
