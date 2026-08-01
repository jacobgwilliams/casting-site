class DivisionPolicy < ApplicationPolicy
  def index?
    user.present? && (org_member? || org_admin?)
  end

  def create?
    user.present? && org_admin? && division_supported?
  end

  def update?
    user.present? && org_admin? && division_supported?
  end

  def destroy?
    update?
  end

  private

  def org_admin?
    organization.organization_memberships.active.exists?(
      user_id: user.id,
      membership_role: %w[owner administrator]
    )
  end

  def org_member?
    organization.organization_memberships.where(status: %w[active invited]).exists?(user_id: user.id)
  end

  def division_supported?
    organization.agency? || organization.management_company?
  end

  def organization
    record.organization
  end
end
