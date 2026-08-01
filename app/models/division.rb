class Division < ApplicationRecord
  belongs_to :organization
  has_many :actor_representation_divisions, dependent: :restrict_with_exception

  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :organization_id }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :active, -> { where(active: true) }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
