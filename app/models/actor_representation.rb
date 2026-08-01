class ActorRepresentation < ApplicationRecord
  STATUSES = %w[pending active declined inactive terminated].freeze

  belongs_to :actor_profile
  belongs_to :organization
  belongs_to :invited_by_user, class_name: "User", optional: true
  has_many :actor_representation_divisions, dependent: :destroy
  has_many :divisions, through: :actor_representation_divisions

  validates :status, inclusion: { in: STATUSES }
  validate :organization_must_be_agency_or_management

  scope :active, -> { where(status: "active") }

  private

  def organization_must_be_agency_or_management
    return if organization.blank?
    return if organization.agency? || organization.management_company?

    errors.add(:organization, "must be an agency or management company")
  end
end
