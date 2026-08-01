class OrganizationSerializer
  def initialize(organization)
    @organization = organization
  end

  def as_json(*)
    {
      id: @organization.id,
      name: @organization.name,
      organization_type: @organization.organization_type,
      status: @organization.status,
      website_url: @organization.website_url,
      phone_number: @organization.phone_number,
      email: @organization.email,
      city: @organization.city,
      state_region: @organization.state_region,
      country_code: @organization.country_code
    }
  end
end
