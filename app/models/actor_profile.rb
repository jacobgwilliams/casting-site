class ActorProfile < ApplicationRecord
  PROFILE_STATUSES = %w[draft active hidden suspended].freeze

  belongs_to :user
  has_many :actor_representations, dependent: :destroy
  has_many :organizations, through: :actor_representations
  has_many :actor_skills, dependent: :destroy
  has_many :skills, through: :actor_skills
  has_many :actor_attributes, dependent: :destroy
  has_many :profile_attributes, through: :actor_attributes

  validates :user_id, uniqueness: true
  validates :profile_status, inclusion: { in: PROFILE_STATUSES }

  def display_name
    professional_name.presence || user.full_name
  end
end
