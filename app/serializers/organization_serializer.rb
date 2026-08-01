class OrganizationSerializer
  def initialize(organization, current_user: nil)
    @organization = organization
    @current_user = current_user
  end

  def as_json(*)
    data = {
      id: @organization.id,
      name: @organization.name,
      organization_type: @organization.organization_type,
      status: @organization.status,
      website_url: @organization.website_url,
      phone_number: @organization.phone_number,
      email: @organization.email,
      city: @organization.city,
      state_region: @organization.state_region,
      country_code: @organization.country_code,
      address_line_1: @organization.address_line_1,
      address_line_2: @organization.address_line_2,
      postal_code: @organization.postal_code
    }

    if @current_user
      membership = @organization.organization_memberships.find_by(user_id: @current_user.id)
      data[:current_membership] = membership ? OrganizationMembershipSerializer.new(membership).as_json : nil
    end

    data
  end
end
