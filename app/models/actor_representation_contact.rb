class ActorRepresentationContact < ApplicationRecord
  belongs_to :actor_representation_division
  belongs_to :representative_profile

  validate :representative_belongs_to_organization

  private

  def representative_belongs_to_organization
    return if actor_representation_division.blank? || representative_profile.blank?

    organization_id = actor_representation_division.actor_representation.organization_id
    user_id = representative_profile.user_id

    membership_exists = OrganizationMembership.active.exists?(
      organization_id: organization_id,
      user_id: user_id,
      membership_role: %w[agent manager owner administrator]
    )

    return if membership_exists

    errors.add(:representative_profile, "must be an active agent or manager at the organization")
  end
end
