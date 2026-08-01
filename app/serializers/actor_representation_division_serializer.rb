class ActorRepresentationDivisionSerializer
  def initialize(representation_division, include_contacts: true)
    @representation_division = representation_division
    @include_contacts = include_contacts
  end

  def as_json(*)
    data = {
      id: @representation_division.id,
      actor_representation_id: @representation_division.actor_representation_id,
      division_id: @representation_division.division_id,
      division_name: @representation_division.division.name,
      division_slug: @representation_division.division.slug,
      status: @representation_division.status,
      started_on: @representation_division.started_on,
      ended_on: @representation_division.ended_on
    }

    if @include_contacts
      data[:contacts] = @representation_division.actor_representation_contacts.map { |contact|
        ActorRepresentationContactSerializer.new(contact).as_json
      }
    end

    data
  end
end
