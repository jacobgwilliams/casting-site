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

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
