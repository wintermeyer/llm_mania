class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :gender, :lang ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :gender, :lang ])
  end

  def set_locale
    # Skip locale detection in test environment
    return if Rails.env.test?

    # Priority:
    # 1. User preference from params (if present)
    # 2. User preference from session (if present)
    # 3. User preference from user model (if logged in)
    # 4. Browser language preference (if available and supported)
    # 5. Default locale (English)

    locale = if params[:locale].present?
      # Store the locale in session if it comes from params
      session[:locale] = params[:locale]

      # Update user's language preference if they're logged in
      current_user.update_language_preference(params[:locale]) if user_signed_in?

      params[:locale]
    elsif session[:locale].present?
      session[:locale]
    elsif user_signed_in? && current_user.lang.present?
      current_user.lang
    else
      extract_locale_from_browser
    end

    # Ensure the locale is supported, otherwise use default
    I18n.locale = I18n.available_locales.include?(locale.to_sym) ? locale : I18n.default_locale
  end

  def extract_locale_from_browser
    # Extract the first locale from the Accept-Language header
    browser_locale = request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first

    # Check if the browser locale is supported
    if browser_locale && I18n.available_locales.include?(browser_locale.to_sym)
      browser_locale
    else
      I18n.default_locale
    end
  end

  # Include locale in all generated URLs
  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end
end
