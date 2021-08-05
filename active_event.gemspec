# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "active_event/version"

Gem::Specification.new do |spec|
  spec.name          = "active_event"
  spec.version       = ActiveEvent::Version::STRING
  spec.authors       = ["Alexandre Saldanha"]
  spec.email         = ["absaldanha@protonmail.com"]
  spec.summary       = "Micro framework for event sourcing in Rails"
  spec.license       = "MIT"

  spec.required_ruby_version = [">= 2.5.0", "< 3.0"]

  spec.metadata = {
    "source_code_uri" => "https://github.com/absaldanha/active_event"
  }

  spec.files = Dir["lib/**/*"]

  spec.require_path = "lib"

  spec.add_dependency "activesupport", ">= 5.2"
  spec.add_dependency "activejob", ">= 5.2"
  spec.add_dependency "zeitwerk", "~> 2.4"
  spec.add_dependency "dry-configurable", "0.12.1"

  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "minitest-focus", "~> 1.2"
  spec.add_development_dependency "minitest-reporters", "~> 1.4"
  spec.add_development_dependency "pry-byebug", "~> 3.7"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.18"
  spec.add_development_dependency "rubocop-performance", "~> 1.11"
  spec.add_development_dependency "simplecov", "0.21.2"
end
