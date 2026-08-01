class Organization < ApplicationRecord
  TYPES = %w[casting_office agency management_company].freeze
  STATUSES = %w[active inactive suspended].freeze

  CASTING_ROLES = %w[owner administrator casting_director casting_associate casting_assistant staff].freeze
  AGENCY_ROLES = %w[owner administrator agent staff].freeze
  MANAGEMENT_ROLES = %w[owner administrator manager staff].freeze

  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships
  has_many :divisions, dependent: :destroy
  has_many :actor_representations, dependent: :restrict_with_exception
  has_many :projects, foreign_key: :casting_office_id, inverse_of: :casting_office, dependent: :nullify

  validates :name, presence: true
  validates :organization_type, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :casting_offices, -> { where(organization_type: "casting_office") }
  scope :agencies, -> { where(organization_type: "agency") }
  scope :management_companies, -> { where(organization_type: "management_company") }

  def casting_office?
    organization_type == "casting_office"
  end

  def agency?
    organization_type == "agency"
  end

  def management_company?
    organization_type == "management_company"
  end

  def allowed_membership_roles
    case organization_type
    when "casting_office" then CASTING_ROLES
    when "agency" then AGENCY_ROLES
    when "management_company" then MANAGEMENT_ROLES
    else []
    end
  end
end
