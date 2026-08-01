class Project < ApplicationRecord
  TYPES = %w[
    feature_film
    short_film
    television
    commercial
    theater
    voice_over
    print
    industrial
    new_media
    student_film
    other
  ].freeze

  STATUSES = %w[draft active paused completed cancelled archived].freeze

  belongs_to :casting_office, class_name: "Organization", optional: true
  belongs_to :created_by_user, class_name: "User"
  has_many :project_casting_team_members, dependent: :destroy
  has_many :organization_memberships, through: :project_casting_team_members
  has_many :breakdowns, dependent: :destroy

  validates :name, presence: true
  validates :project_type, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }
  validate :casting_office_must_be_casting_office

  scope :active, -> { where(status: "active") }
  scope :published, -> { where.not(published_at: nil) }

  def active?
    status == "active"
  end

  private

  def casting_office_must_be_casting_office
    return if casting_office.blank?
    return if casting_office.casting_office?

    errors.add(:casting_office, "must be a casting office organization")
  end
end
