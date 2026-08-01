class Breakdown < ApplicationRecord
  STATUSES = %w[draft published paused closed cancelled archived].freeze
  VISIBILITIES = %w[representatives_only public private].freeze

  belongs_to :project
  belongs_to :created_by_user, class_name: "User"
  has_one :breakdown_criterion, class_name: "BreakdownCriterion", dependent: :destroy
  has_many :breakdown_access_grants, dependent: :destroy
  has_many :breakdown_skill_requirements, dependent: :destroy
  has_many :skills, through: :breakdown_skill_requirements
  has_many :breakdown_attribute_requirements, dependent: :destroy
  has_many :profile_attributes, through: :breakdown_attribute_requirements

  validates :character_name, :description, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :number_of_roles, numericality: { greater_than: 0 }

  scope :published, -> { where(status: "published") }
  scope :publicly_visible, -> { where(visibility: "public") }

  def published?
    status == "published"
  end

  def accessible_by?(user)
    return true if visibility == "public"
    return true if project.created_by_user_id == user.id
    return true if project.project_casting_team_members.joins(:organization_membership)
      .exists?(organization_memberships: { user_id: user.id })

    case visibility
    when "representatives_only"
      user.active_representative?
    when "private"
      breakdown_access_grants.active_for(user).exists?
    else
      false
    end
  end
end
