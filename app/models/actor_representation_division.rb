class ActorRepresentationDivision < ApplicationRecord
  STATUSES = %w[active inactive ended].freeze

  belongs_to :actor_representation
  belongs_to :division
  has_many :actor_representation_contacts, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }
  validates :division_id, uniqueness: {
    scope: [ :actor_representation_id, :started_on ],
    message: "already linked for this start date"
  }
  validate :division_belongs_to_representation_organization

  scope :active, -> { where(status: "active") }

  private

  def division_belongs_to_representation_organization
    return if actor_representation.blank? || division.blank?
    return if division.organization_id == actor_representation.organization_id

    errors.add(:division, "must belong to the representation organization")
  end
end
