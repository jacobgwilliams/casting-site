class BreakdownAttributeRequirement < ApplicationRecord
  LEVELS = %w[required preferred nice_to_have].freeze

  belongs_to :breakdown
  belongs_to :profile_attribute

  validates :requirement_level, inclusion: { in: LEVELS }
  validates :profile_attribute_id, uniqueness: { scope: :breakdown_id }
end
