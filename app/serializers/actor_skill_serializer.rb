class ActorSkillSerializer
  def initialize(actor_skill)
    @actor_skill = actor_skill
  end

  def as_json(*)
    {
      id: @actor_skill.id,
      skill_id: @actor_skill.skill_id,
      skill_name: @actor_skill.skill.name,
      skill_category: @actor_skill.skill.category,
      proficiency: @actor_skill.proficiency,
      years_experience: @actor_skill.years_experience,
      notes: @actor_skill.notes,
      verified: @actor_skill.verified
    }
  end
end
