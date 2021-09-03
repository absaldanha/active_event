# frozen_string_literal: true

module BroadcasterHelper
  def with_test_broadcaster
    old_broadcaster = ActiveEvent.config.broadcaster.name
    ActiveEvent.config.broadcaster = :test

    yield
  ensure
    ActiveEvent.config.broadcaster = old_broadcaster
  end

  def with_default_broadcaster
    old_broadcaster = ActiveEvent.config.broadcaster.name
    ActiveEvent.config.broadcaster = :default

    yield
  ensure
    ActiveEvent.config.broadcaster = old_broadcaster
  end
end
