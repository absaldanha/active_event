# frozen_string_literal: true

module ActiveEvent
  module EventBuses
    def self.lookup(name)
      case name
      when "default"
        DefaultEventBus
      when "test"
        TestEventBus
      else
        raise InvalidEventBus, name
      end
    end
  end
end
