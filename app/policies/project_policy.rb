class ProjectPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (owner_or_team_member? || record.status == "active")
  end

  def create?
    user.casting_professional?
  end

  def update?
    owner_or_team_member?
  end

  def destroy?
    owner_or_team_member?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def owner_or_team_member?
    record.created_by_user_id == user.id ||
      record.project_casting_team_members.joins(:organization_membership)
        .exists?(organization_memberships: { user_id: user.id, status: "active" })
  end
end
