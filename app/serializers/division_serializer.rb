class DivisionSerializer
  def initialize(division)
    @division = division
  end

  def as_json(*)
    {
      id: @division.id,
      organization_id: @division.organization_id,
      name: @division.name,
      slug: @division.slug,
      description: @division.description,
      active: @division.active
    }
  end
end
