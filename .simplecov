# frozen_string_literal: true

SimpleCov.start do
  add_filter "/test/"

  minimum_coverage 100
  refuse_coverage_drop
end
