# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    user ||= User.new # guest user (not logged in)

    if user.is_admin?
      # Admin users can manage everything
      can :manage, :all
    elsif user.persisted?
      # Regular logged in users can manage their own account
      can :manage, User, id: user.id
      can :read, LlmModel, is_active: true
      can :read, Plan, is_active: true

      # Users can read and delete their own prompt jobs
      can [ :read, :create, :destroy ], PromptJob, user_id: user.id
    else
      # Non-logged in users can only read active models and plans
      can :read, LlmModel, is_active: true
      can :read, Plan, is_active: true
    end

    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
