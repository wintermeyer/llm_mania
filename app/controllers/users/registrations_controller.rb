class Users::RegistrationsController < Devise::RegistrationsController
  # Override the create method to customize the redirect after registration
  def create
    super do |resource|
      # If the user was saved successfully but needs confirmation
      if resource.persisted? && resource.inactive_message == :unconfirmed
        # Store the resource in the session to access it after redirect
        session[:user_needs_confirmation] = true
      end
    end
  end

  protected

  # Override the after_sign_up_path_for method to redirect to a custom page
  def after_sign_up_path_for(resource)
    if session[:user_needs_confirmation]
      session.delete(:user_needs_confirmation)
      # Redirect to the root path with a flash message
      flash[:notice] = I18n.t("devise.registrations.signed_up_but_unconfirmed")
      root_path
    else
      super
    end
  end
end
