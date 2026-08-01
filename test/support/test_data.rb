module TestData
  PASSWORD = "password123"

  module_function

  def create_user(email:, first_name: "Test", last_name: "User", **attrs)
    User.create!(
      {
        email: email,
        password: PASSWORD,
        password_confirmation: PASSWORD,
        first_name: first_name,
        last_name: last_name,
        status: "active"
      }.merge(attrs)
    )
  end

  def create_casting_office(name: "Test Casting Office")
    Organization.create!(
      name: name,
      organization_type: "casting_office",
      status: "active",
      city: "Chicago",
      state_region: "IL",
      country_code: "US"
    )
  end

  def create_agency(name: "Test Talent Agency")
    Organization.create!(
      name: name,
      organization_type: "agency",
      status: "active",
      city: "Chicago",
      state_region: "IL",
      country_code: "US"
    )
  end

  def create_casting_user(email: "casting@test.example")
    user = create_user(email: email, first_name: "Casey", last_name: "Director")
    user.create_casting_professional_profile!
    office = create_casting_office
    OrganizationMembership.create!(
      organization: office,
      user: user,
      membership_role: "owner",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    { user: user, office: office }
  end

  def create_actor_user(email: "actor@test.example")
    user = create_user(email: email, first_name: "Alex", last_name: "Actor")
    user.create_actor_profile!(professional_name: "Alex Actor", profile_status: "active")
    user
  end

  def create_agent_user(email: "agent@test.example")
    user = create_user(email: email, first_name: "Jordan", last_name: "Agent")
    user.create_representative_profile!(representative_type: "agent")
    agency = create_agency
    OrganizationMembership.create!(
      organization: agency,
      user: user,
      membership_role: "agent",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    user
  end

  def create_agency_owner(email: nil)
    email ||= "owner-agent-#{SecureRandom.hex(4)}@test.example"
    user = create_user(email: email, first_name: "Jordan", last_name: "Agent")
    user.create_representative_profile!(representative_type: "agent")
    agency = create_agency(name: "Example Talent Agency")
    OrganizationMembership.create!(
      organization: agency,
      user: user,
      membership_role: "owner",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    { user: user, agency: agency }
  end

  def create_agency_with_divisions(email: nil)
    setup = create_agency_owner(email: email)
    agency = setup[:agency]
    commercial = Division.find_or_create_by!(organization: agency, slug: "commercial") do |division|
      division.name = "Commercial"
      division.active = true
    end
    legit = Division.find_or_create_by!(organization: agency, slug: "legit") do |division|
      division.name = "Film and Television"
      division.active = true
    end
    setup.merge(divisions: { commercial: commercial, legit: legit })
  end

  def create_project(casting_user:, office:, **attrs)
    project = Project.create!(
      {
        name: "Test Project",
        project_type: "commercial",
        description: "Test project description",
        status: "active",
        casting_office: office,
        created_by_user: casting_user,
        published_at: Time.current
      }.merge(attrs)
    )

    membership = casting_user.organization_memberships.active.find_by!(organization: office)
    ProjectCastingTeamMember.find_or_create_by!(project: project, organization_membership: membership) do |member|
      member.project_role = "casting_director"
      member.permissions = {
        can_edit_project: true,
        can_manage_breakdowns: true,
        can_review_submissions: true,
        can_invite_team_members: true
      }
    end

    project
  end

  def create_breakdown(project:, created_by_user:, visibility: "public", status: "published", **attrs)
    Breakdown.create!(
      {
        project: project,
        created_by_user: created_by_user,
        character_name: "Lead Friend",
        description: "Warm, energetic friend.",
        role_type: "principal",
        status: status,
        visibility: visibility,
        number_of_roles: 1,
        published_at: status == "published" ? Time.current : nil
      }.merge(attrs)
    )
  end
end
