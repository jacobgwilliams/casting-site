class ActorSkillPolicy < ApplicationPolicy
  def index?
    user.present? && user.actor?
  end

  def create?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user.actor?

      scope.where(actor_profile_id: user.actor_profile.id)
    end
  end

  private

  def owner?
    user.present? && user.actor? && record.actor_profile.user_id == user.id
  end
end
