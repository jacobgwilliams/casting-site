class ActorAttribute < ApplicationRecord
  VISIBILITIES = %w[public representatives casting_only private].freeze

  belongs_to :actor_profile
  belongs_to :profile_attribute

  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :profile_attribute_id, uniqueness: { scope: :actor_profile_id }
end
