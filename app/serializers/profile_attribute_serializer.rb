class ProfileAttributeSerializer
  def initialize(profile_attribute)
    @profile_attribute = profile_attribute
  end

  def as_json(*)
    {
      id: @profile_attribute.id,
      name: @profile_attribute.name,
      category: @profile_attribute.category,
      slug: @profile_attribute.slug,
      is_sensitive: @profile_attribute.is_sensitive
    }
  end
end
