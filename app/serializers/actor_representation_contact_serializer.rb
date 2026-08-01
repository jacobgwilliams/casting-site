class ActorRepresentationContactSerializer
  def initialize(contact)
    @contact = contact
  end

  def as_json(*)
    {
      id: @contact.id,
      actor_representation_division_id: @contact.actor_representation_division_id,
      representative_profile_id: @contact.representative_profile_id,
      representative_name: @contact.representative_profile.user.full_name,
      is_primary: @contact.is_primary,
      started_on: @contact.started_on,
      ended_on: @contact.ended_on
    }
  end
end
