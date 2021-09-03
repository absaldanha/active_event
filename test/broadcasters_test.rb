# frozen_string_literal: true

require "test_helper"

module ActiveEvent
  class BroadcastersTest < Minitest::Test
    def teardown
      default_identifiers = [:default, :test]

      ActiveEvent::Broadcasters.registred_broadcasters.each do |identifier, _|
        unless default_identifiers.include?(identifier)
          ActiveEvent::Broadcasters.unregister(identifier)
        end
      end
    end

    def test_default_registred_broadcasters
      registred_broadcasters = ActiveEvent::Broadcasters.registred_broadcasters

      assert_equal 2, registred_broadcasters.size

      assert_equal(
        ActiveEvent::Broadcasters::DefaultBroadcaster,
        registred_broadcasters[:default]
      )
      assert_equal(
        ActiveEvent::Broadcasters::TestBroadcaster,
        registred_broadcasters[:test]
      )
    end

    def test_register_adds_broadcaster_class_with_given_identifier
      ActiveEvent::Broadcasters.register(:dummy, Object)

      assert_equal 3, ActiveEvent::Broadcasters.registred_broadcasters.size
      assert_equal(
        Object,
        ActiveEvent::Broadcasters.registred_broadcasters[:dummy]
      )
    end

    def test_unregister_removes_broadcaster_with_given_identifier
      ActiveEvent::Broadcasters.register(:dummy, Object)

      assert_equal 3, ActiveEvent::Broadcasters.registred_broadcasters.size
      assert_equal(
        Object,
        ActiveEvent::Broadcasters.registred_broadcasters[:dummy]
      )

      ActiveEvent::Broadcasters.unregister(:dummy)

      assert_equal 2, ActiveEvent::Broadcasters.registred_broadcasters.size
      refute ActiveEvent::Broadcasters.registred_broadcasters.key?(:dummy)
    end

    def test_lookup_gets_broadcaster_identified_by_given_identifier
      assert_equal(
        ActiveEvent::Broadcasters::DefaultBroadcaster,
        ActiveEvent::Broadcasters.lookup(:default)
      )
    end

    def test_lookup_raises_when_unknown_identifier
      assert_raises InvalidBroadcaster do
        ActiveEvent::Broadcasters.lookup(:unknown)
      end
    end
  end
end
