class OrganizationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    membership = record.organization_memberships.active.find_by(user_id: user.id)
    membership&.membership_role.in?(%w[owner administrator])
  end

  def destroy?
    record.organization_memberships.active.exists?(
      user_id: user.id,
      membership_role: "owner"
    )
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.active
    end
  end
end
