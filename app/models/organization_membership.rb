class OrganizationMembership < ApplicationRecord
  ROLES = %w[
    owner
    administrator
    casting_director
    casting_associate
    casting_assistant
    agent
    manager
    staff
  ].freeze

  STATUSES = %w[invited active inactive removed].freeze

  belongs_to :organization
  belongs_to :user
  has_many :project_casting_team_members, dependent: :restrict_with_exception

  validates :membership_role, inclusion: { in: ROLES }
  validates :status, inclusion: { in: STATUSES }
  validates :membership_role, uniqueness: {
    scope: [ :organization_id, :user_id, :started_on ],
    message: "already exists for this user, organization, and start date"
  }
  validate :role_matches_organization_type
  validate :user_persona_matches_role, on: :create

  scope :active, -> { where(status: "active") }

  def active?
    status == "active"
  end

  def invited?
    status == "invited"
  end

  def removed?
    status == "removed"
  end

  private

  def role_matches_organization_type
    return if organization.blank? || membership_role.blank?
    return if organization.allowed_membership_roles.include?(membership_role)

    errors.add(
      :membership_role,
      "'#{membership_role}' is not valid for a #{organization.organization_type}"
    )
  end

  def user_persona_matches_role
    return if user.blank? || membership_role.blank?
    return if membership_role.in?(%w[owner administrator staff])

    case membership_role
    when "casting_director", "casting_associate", "casting_assistant"
      unless user.casting_professional?
        errors.add(:membership_role, "requires a casting professional profile")
      end
    when "agent"
      unless user.representative_profile&.agent?
        errors.add(:membership_role, "requires an agent profile")
      end
    when "manager"
      unless user.representative_profile&.manager?
        errors.add(:membership_role, "requires a manager profile")
      end
    end
  end
end
