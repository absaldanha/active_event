# frozen_string_literal: true

require "test_helper"

module ActiveEvent
  class VersionTest < Minitest::Test
    def test_version_string
      assert_equal "0.1.0", Version::STRING
    end
  end
end
