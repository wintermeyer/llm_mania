# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here.
    # Anonymous user (not logged in)
    return if user.nil?

    # Logged in user with any role
    can :read, Prompt, hidden: false, private: false
    can :read, Llm, active: true
    can :read, Rating
    can :read, Subscription, active: true

    # User can manage their own resources
    can :manage, Prompt, user_id: user.id
    can :manage, Rating, user_id: user.id
    can :create, PromptReport
    can :manage, PromptReport, user_id: user.id

    # Regular users can view their own subscription history
    # This applies even if current_role is nil
    can :read, SubscriptionHistory, user_id: user.id

    # Role-specific abilities
    # Primary check is based on current_role.name

    # Admin role - check current_role first
    if user.current_role.present? && user.current_role.name == "admin"
      # Admins can manage everything when their current role is admin
      can :manage, :all
    end
  end
end
