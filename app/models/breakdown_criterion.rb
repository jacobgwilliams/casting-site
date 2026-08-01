class BreakdownCriterion < ApplicationRecord
  self.table_name = "breakdown_criteria"

  belongs_to :breakdown

  validates :breakdown_id, uniqueness: true
  validate :age_range_is_valid

  private

  def age_range_is_valid
    return if portrayal_age_min.blank? || portrayal_age_max.blank?
    return if portrayal_age_min <= portrayal_age_max

    errors.add(:portrayal_age_max, "must be greater than or equal to portrayal_age_min")
  end
end
