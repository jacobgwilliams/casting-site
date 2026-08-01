class CastingProfessionalProfileSerializer
  def initialize(casting_professional_profile)
    @casting_professional_profile = casting_professional_profile
  end

  def as_json(*)
    {
      id: @casting_professional_profile.id,
      professional_title: @casting_professional_profile.professional_title
    }
  end
end
