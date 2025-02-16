ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add FactoryBot methods
    include FactoryBot::Syntax::Methods

    # Add more helper methods to be used by all tests here...
    setup do
      # Always use English in tests
      I18n.locale = :en
      I18n.default_locale = :en
      Rails.application.config.i18n.default_locale = :en
      Rails.application.config.i18n.locale = :en
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
  end

  teardown do
    Warden.test_reset!
  end
end

class ActionDispatch::SystemTestCase
  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
    Warden.test_reset!
    Warden.on_next_request do |proxy|
      proxy.raw_session[:_csrf_token] = "test_csrf_token"
    end
  end

  teardown do
    Warden.test_reset!
  end
end
