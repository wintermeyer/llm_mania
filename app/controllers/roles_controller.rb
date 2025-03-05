class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_development_environment
  before_action :ensure_user_has_role, only: [:switch]
  load_and_authorize_resource only: [:switch]

  # POST /roles/:id/switch
  def switch
    role = Role.find(params[:id])

    if current_user.update(current_role: role)
      redirect_back(fallback_location: root_path, notice: "Switched to #{role.name} role")
    else
      redirect_back(fallback_location: root_path, alert: "Failed to switch role")
    end
  end

  private

  def ensure_development_environment
    unless Rails.env.development?
      redirect_to root_path, alert: "This feature is only available in development environment"
    end
  end

  def ensure_user_has_role
    role = Role.find(params[:id])
    unless current_user.roles.include?(role)
      redirect_to root_path, alert: "You don't have access to this role"
    end
  end
end
