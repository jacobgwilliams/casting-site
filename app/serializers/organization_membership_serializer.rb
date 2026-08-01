class OrganizationMembershipSerializer
  def initialize(membership, include_organization: false)
    @membership = membership
    @include_organization = include_organization
  end

  def as_json(*)
    data = {
      id: @membership.id,
      organization_id: @membership.organization_id,
      user_id: @membership.user_id,
      user_email: @membership.user.email,
      user_full_name: @membership.user.full_name,
      membership_role: @membership.membership_role,
      job_title: @membership.job_title,
      status: @membership.status,
      started_on: @membership.started_on,
      ended_on: @membership.ended_on,
      invited_at: @membership.invited_at,
      accepted_at: @membership.accepted_at
    }

    if @include_organization
      data[:organization] = OrganizationSerializer.new(@membership.organization).as_json
    end

    data
  end
end
