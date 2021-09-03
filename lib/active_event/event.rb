# frozen_string_literal: true

module ActiveEvent
  module Event
    attr_reader :payload

    def initialize(payload = {})
      @payload = payload.transform_keys(&:to_sym)
    end

    def name
      @name ||= self.class.name.demodulize.remove("Event").underscore
    end

    def dispatch
      ActiveEvent.dispatch(self)
    end

    def ==(other)
      other.class == self.class &&
        other.payload == payload
    end
  end
end
