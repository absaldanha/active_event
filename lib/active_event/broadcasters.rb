# frozen_string_literal: true

module ActiveEvent
  module Broadcasters
    mattr_reader :registred_broadcasters, instance_accessor: false, default: {}

    def self.register(identifier, broadcaster)
      registred_broadcasters[identifier.to_sym] = broadcaster
    end

    def self.unregister(identifier)
      registred_broadcasters.delete(identifier.to_sym)
    end

    def self.lookup(identifier)
      registred_broadcasters.fetch(identifier.to_sym) do
        raise InvalidBroadcaster, identifier
      end
    end
  end
end

ActiveEvent::Broadcasters.register(
  :default,
  ActiveEvent::Broadcasters::DefaultBroadcaster
)
ActiveEvent::Broadcasters.register(
  :test,
  ActiveEvent::Broadcasters::TestBroadcaster
)
