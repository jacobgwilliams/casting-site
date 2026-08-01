class ActorRepresentationSerializer
  def initialize(representation, include_divisions: true)
    @representation = representation
    @include_divisions = include_divisions
  end

  def as_json(*)
    data = {
      id: @representation.id,
      actor_profile_id: @representation.actor_profile_id,
      actor_name: @representation.actor_profile.display_name,
      organization_id: @representation.organization_id,
      organization_name: @representation.organization.name,
      organization_type: @representation.organization.organization_type,
      status: @representation.status,
      exclusive: @representation.exclusive,
      started_on: @representation.started_on,
      ended_on: @representation.ended_on,
      notes: @representation.notes,
      confirmed_at: @representation.confirmed_at
    }

    if @include_divisions
      data[:divisions] = @representation.actor_representation_divisions.includes(
        :division, actor_representation_contacts: { representative_profile: :user }
      ).map { |record|
        ActorRepresentationDivisionSerializer.new(record).as_json
      }
    end

    data
  end
end
