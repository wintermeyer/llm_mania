ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Include FactoryBot syntax methods
    include FactoryBot::Syntax::Methods

    # Force English locale for all tests
    setup do
      I18n.locale = :en
      I18n.default_locale = :en
      Rails.application.config.i18n.default_locale = :en
      Rails.application.config.i18n.locale = :en
      Rails.application.config.i18n.available_locales = [ :en, :de ]
    end

    teardown do
      I18n.locale = :en
    end

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

class ActionDispatch::SystemTestCase
  include Devise::Test::IntegrationHelpers

  # Set up Devise mappings for system tests
  setup do
    @request ||= ActionDispatch::TestRequest.create
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
