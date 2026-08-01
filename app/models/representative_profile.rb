class RepresentativeProfile < ApplicationRecord
  TYPES = %w[agent manager].freeze

  belongs_to :user
  has_many :actor_representation_contacts, dependent: :restrict_with_exception

  validates :user_id, uniqueness: true
  validates :representative_type, inclusion: { in: TYPES }

  def agent?
    representative_type == "agent"
  end

  def manager?
    representative_type == "manager"
  end
end
