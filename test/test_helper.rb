# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
end

require "bundler/setup"
require "active_event"
require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

ActiveJob::Base.logger = Logger.new(IO::NULL)

module Minitest
  class Test
    def setup
      ActiveEvent.event_bus.clear!
    end
  end
end
