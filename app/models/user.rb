class User < ApplicationRecord
  has_secure_password

  STATUSES = %w[active invited suspended deactivated].freeze

  has_many :sessions, dependent: :destroy
  has_one :actor_profile, dependent: :destroy
  has_one :casting_professional_profile, dependent: :destroy
  has_one :representative_profile, dependent: :destroy
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :created_projects, class_name: "Project", foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :restrict_with_exception
  has_many :created_breakdowns, class_name: "Breakdown", foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :restrict_with_exception

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :status, inclusion: { in: STATUSES }

  normalizes :email, with: ->(email) { email.strip.downcase }

  def full_name
    "#{first_name} #{last_name}"
  end

  def active?
    status == "active"
  end

  def active_representative?
    return false unless representative_profile

    organization_memberships.active.where(membership_role: %w[agent manager]).exists?
  end

  def actor?
    actor_profile.present?
  end

  def casting_professional?
    casting_professional_profile.present?
  end

  def representative?
    representative_profile.present?
  end
end
