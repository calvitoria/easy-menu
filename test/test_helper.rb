# test/test_helper.rb
require "simplecov"
SimpleCov.start "rails"
SimpleCov.minimum_coverage 90

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # parallelize(workers: :number_of_processors) - simplecov

    self.use_transactional_tests = true
    include FactoryBot::Syntax::Methods
  end
end
