class ActorAttributeSerializer
  def initialize(actor_attribute)
    @actor_attribute = actor_attribute
  end

  def as_json(*)
    {
      id: @actor_attribute.id,
      profile_attribute_id: @actor_attribute.profile_attribute_id,
      profile_attribute_name: @actor_attribute.profile_attribute.name,
      profile_attribute_category: @actor_attribute.profile_attribute.category,
      visibility: @actor_attribute.visibility,
      verified: @actor_attribute.verified
    }
  end
end
