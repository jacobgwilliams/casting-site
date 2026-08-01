class BreakdownSkillRequirement < ApplicationRecord
  LEVELS = %w[required preferred nice_to_have].freeze

  belongs_to :breakdown
  belongs_to :skill

  validates :requirement_level, inclusion: { in: LEVELS }
  validates :skill_id, uniqueness: { scope: :breakdown_id }
end
