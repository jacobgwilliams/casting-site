class ActorProfileSerializer
  def initialize(actor_profile)
    @actor_profile = actor_profile
  end

  def as_json(*)
    {
      id: @actor_profile.id,
      professional_name: @actor_profile.professional_name,
      union_status: @actor_profile.union_status,
      primary_location: @actor_profile.primary_location,
      timezone: @actor_profile.timezone,
      profile_status: @actor_profile.profile_status,
      display_name: @actor_profile.display_name
    }
  end
end
