class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  private

  def set_locale
    return if Rails.env.test? # Skip locale detection in test environment
    I18n.locale = extract_locale_from_accept_language_header || I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    return unless request.env["HTTP_ACCEPT_LANGUAGE"]

    # Get the first locale from the Accept-Language header
    preferred_language = request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first

    # Only return the locale if it's one we support
    preferred_language if I18n.available_locales.include?(preferred_language.to_sym)
  end
end
