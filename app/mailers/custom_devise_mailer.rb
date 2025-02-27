class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  # Override the default method to use locale-specific templates
  def headers_for(action, opts)
    headers = super

    # Get the user's language or default to English
    locale = resource.try(:lang) || I18n.default_locale

    # Ensure locale is a symbol and valid (either 'en' or 'de')
    locale = locale.to_s.downcase
    locale = I18n.default_locale.to_s unless %w[en de].include?(locale)

    # Set the locale for this email
    I18n.with_locale(locale) do
      # Modify the template path to include the locale
      @template = "#{locale}/#{action}"
    end

    headers
  end
end
