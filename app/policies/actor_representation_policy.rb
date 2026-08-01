class ActorRepresentationPolicy < ApplicationPolicy
  def index?
    user.present? && (user.actor? || user.representative?)
  end

  def show?
    return false unless user.present?

    actor_owner? || org_rep_member? || org_admin?
  end

  def create?
    return false unless user.present?

    actor_requesting_own_rep? || org_admin?
  end

  def update?
    return false unless user.present?

    actor_owner? || org_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.actor?
        scope.where(actor_profile_id: user.actor_profile.id)
      elsif user.representative?
        org_ids = user.organization_memberships.active.joins(:organization).where(
          organizations: { organization_type: %w[agency management_company] }
        ).select(:organization_id)
        scope.where(organization_id: org_ids)
      else
        scope.none
      end
    end
  end

  private

  def actor_owner?
    user.actor? && record.actor_profile.user_id == user.id
  end

  def actor_requesting_own_rep?
    actor_owner? && record.actor_profile_id == user.actor_profile.id
  end

  def org_admin?
    record.organization.organization_memberships.active.exists?(
      user_id: user.id,
      membership_role: %w[owner administrator]
    )
  end

  def org_rep_member?
    return false unless user.representative?

    record.organization.organization_memberships.active.exists?(
      user_id: user.id,
      membership_role: %w[agent manager owner administrator]
    )
  end
end
