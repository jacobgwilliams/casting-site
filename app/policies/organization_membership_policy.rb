class OrganizationMembershipPolicy < ApplicationPolicy
  def index?
    user.present? && (org_member? || org_admin?)
  end

  def create?
    return false unless user.present?

    if self_join?
      record.user_id == user.id
    else
      org_admin?
    end
  end

  def update?
    return false unless user.present?

    org_admin? || (record.user_id == user.id && record.invited?)
  end

  def destroy?
    return false unless user.present?

    org_admin? || record.user_id == user.id
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

  def self_join?
    record.user_id == user.id
  end

  def organization
    record.organization
  end
end
