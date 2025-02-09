class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Handle CanCanCan authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_back_or_to root_path, alert: exception.message
      end
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end
end
