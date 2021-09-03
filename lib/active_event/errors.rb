# frozen_string_literal: true

module ActiveEvent
  class Error < StandardError; end

  class HandlerMessageError < Error
    def initialize(handler, event)
      message = "Class `#{handler.class.name}` is subscribed to " \
        "`#{event.name}` events, but doesn't implement an " \
        "`#{event.name}` or `handle` method"

      super(message)
    end
  end

  class InvalidBroadcaster < Error
    def initialize(value)
      message = "Invalid broadcaster. Valid broadcasters are " \
        "`:default`, or `:test`, got `#{value.inspect}`"

      super(message)
    end
  end
end
