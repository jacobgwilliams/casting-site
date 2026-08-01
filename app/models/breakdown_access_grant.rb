class BreakdownAccessGrant < ApplicationRecord
  ACCESS_LEVELS = %w[view submit].freeze

  belongs_to :breakdown
  belongs_to :grantee, polymorphic: true

  validates :access_level, inclusion: { in: ACCESS_LEVELS }
  validates :grantee_type, inclusion: { in: %w[User Organization ActorProfile] }

  scope :active_for, ->(user) {
    where(
      "(grantee_type = 'User' AND grantee_id = :user_id) OR " \
      "(grantee_type = 'Organization' AND grantee_id IN (:org_ids)) OR " \
      "(grantee_type = 'ActorProfile' AND grantee_id = :actor_profile_id)",
      user_id: user.id,
      org_ids: user.organization_memberships.active.select(:organization_id),
      actor_profile_id: user.actor_profile&.id
    ).where("expires_at IS NULL OR expires_at > ?", Time.current)
  }
end
