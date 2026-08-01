class BreakdownPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return false unless user.present?
    return true if casting_team_member?
    return false unless record.published? && record.project.active?

    case record.visibility
    when "public"
      true
    when "representatives_only"
      user.active_representative?
    when "private"
      record.accessible_by?(user)
    else
      false
    end
  end

  def create?
    casting_team_member? || record.project.created_by_user_id == user.id
  end

  def update?
    casting_team_member? || record.project.created_by_user_id == user.id
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.select { |breakdown| BreakdownPolicy.new(user, breakdown).show? }
    end
  end

  private

  def casting_team_member?
    record.project.created_by_user_id == user.id ||
      record.project.project_casting_team_members.joins(:organization_membership)
        .exists?(organization_memberships: { user_id: user.id, status: "active" })
  end
end
