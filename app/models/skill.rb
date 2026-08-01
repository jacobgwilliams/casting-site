class Skill < ApplicationRecord
  has_many :actor_skills, dependent: :restrict_with_exception
  has_many :breakdown_skill_requirements, dependent: :restrict_with_exception

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
