class RepresentativeProfileSerializer
  def initialize(representative_profile)
    @representative_profile = representative_profile
  end

  def as_json(*)
    {
      id: @representative_profile.id,
      representative_type: @representative_profile.representative_type
    }
  end
end
