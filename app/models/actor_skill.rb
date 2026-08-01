class ActorSkill < ApplicationRecord
  belongs_to :actor_profile
  belongs_to :skill

  validates :skill_id, uniqueness: { scope: :actor_profile_id }
end
