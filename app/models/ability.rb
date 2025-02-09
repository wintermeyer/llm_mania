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
    else
      can :read, LlmModel, is_active: true
    end

    # Everyone can read public content
    can :read, :all

    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
