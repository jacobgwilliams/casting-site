# frozen_string_literal: true

# Demo data for the first vertical slice:
# casting director creates a project + breakdown; actor and agent can view by visibility.

puts "Seeding casting platform..."

Skill.find_or_create_by!(slug: "horseback-riding") { |s| s.name = "Horseback riding"; s.category = "athletic" }
Skill.find_or_create_by!(slug: "stage-combat") { |s| s.name = "Stage combat"; s.category = "performance" }
Skill.find_or_create_by!(slug: "spanish") { |s| s.name = "Spanish"; s.category = "language" }
Skill.find_or_create_by!(slug: "teleprompter") { |s| s.name = "Teleprompter"; s.category = "on-camera" }

casting_user = User.find_or_initialize_by(email: "casting@example.com")
casting_user.assign_attributes(
  password: "password123",
  first_name: "Casey",
  last_name: "Director",
  status: "active"
)
casting_user.save!
casting_user.create_casting_professional_profile! unless casting_user.casting_professional_profile

actor_user = User.find_or_initialize_by(email: "actor@example.com")
actor_user.assign_attributes(
  password: "password123",
  first_name: "Alex",
  last_name: "Actor",
  status: "active"
)
actor_user.save!
actor_user.create_actor_profile!(professional_name: "Alex Actor", profile_status: "active") unless actor_user.actor_profile

agent_user = User.find_or_initialize_by(email: "agent@example.com")
agent_user.assign_attributes(
  password: "password123",
  first_name: "Jordan",
  last_name: "Agent",
  status: "active"
)
agent_user.save!
agent_user.create_representative_profile!(representative_type: "agent") unless agent_user.representative_profile

office = Organization.find_or_create_by!(name: "Example Casting Office", organization_type: "casting_office") do |org|
  org.city = "Chicago"
  org.state_region = "IL"
  org.country_code = "US"
end

agency = Organization.find_or_create_by!(name: "Example Talent Agency", organization_type: "agency") do |org|
  org.city = "Chicago"
  org.state_region = "IL"
  org.country_code = "US"
end

OrganizationMembership.find_or_create_by!(
  organization: office,
  user: casting_user,
  membership_role: "casting_director",
  started_on: Date.current
) do |m|
  m.status = "active"
  m.accepted_at = Time.current
end

OrganizationMembership.find_or_create_by!(
  organization: agency,
  user: agent_user,
  membership_role: "agent",
  started_on: Date.current
) do |m|
  m.status = "active"
  m.accepted_at = Time.current
end

Division.find_or_create_by!(organization: agency, slug: "commercial") do |d|
  d.name = "On-Camera Commercial"
  d.active = true
end

Division.find_or_create_by!(organization: agency, slug: "legit") do |d|
  d.name = "Film and Television"
  d.active = true
end

commercial_division = Division.find_by!(organization: agency, slug: "commercial")

representation = ActorRepresentation.find_or_create_by!(
  actor_profile: actor_user.actor_profile,
  organization: agency
) do |record|
  record.status = "active"
  record.started_on = Date.current
  record.confirmed_at = Time.current
end
representation.update!(status: "active", confirmed_at: Time.current) unless representation.active?

ActorRepresentationDivision.find_or_create_by!(
  actor_representation: representation,
  division: commercial_division
) do |record|
  record.status = "active"
  record.started_on = Date.current
end

project = Project.find_or_initialize_by(name: "Summer Soft Drink Spot")
project.assign_attributes(
  project_type: "commercial",
  description: "National commercial for a soft drink brand.",
  status: "active",
  casting_office: office,
  created_by_user: casting_user,
  production_company_name: "Example Productions",
  location_summary: "Chicago, IL",
  published_at: Time.current
)
project.save!

membership = casting_user.organization_memberships.find_by!(organization: office)
ProjectCastingTeamMember.find_or_create_by!(project: project, organization_membership: membership) do |member|
  member.project_role = "casting_director"
  member.permissions = {
    can_edit_project: true,
    can_manage_breakdowns: true,
    can_review_submissions: true,
    can_invite_team_members: true
  }
end

public_breakdown = Breakdown.find_or_initialize_by(project: project, character_name: "Lead Friend")
public_breakdown.assign_attributes(
  description: "Warm, energetic friend who shares a soda on a sunny rooftop.",
  role_type: "principal",
  status: "published",
  visibility: "public",
  number_of_roles: 1,
  created_by_user: casting_user,
  published_at: Time.current,
  location_details: "Chicago"
)
public_breakdown.save!

public_breakdown.create_breakdown_criterion!(
  portrayal_age_min: 22,
  portrayal_age_max: 35,
  gender_presentation: "any",
  union_requirement: "SAG-AFTRA",
  local_hire_required: true,
  required_location: "Chicago"
) unless public_breakdown.breakdown_criterion

spanish = Skill.find_by!(slug: "spanish")
public_breakdown.breakdown_skill_requirements.find_or_create_by!(skill: spanish) do |req|
  req.requirement_level = "preferred"
  req.minimum_proficiency = "conversational"
end

rep_only = Breakdown.find_or_initialize_by(project: project, character_name: "Brand Spokesperson")
rep_only.assign_attributes(
  description: "Confident on-camera spokesperson. Representatives only for first week.",
  role_type: "principal",
  status: "published",
  visibility: "representatives_only",
  number_of_roles: 1,
  created_by_user: casting_user,
  published_at: Time.current
)
rep_only.save!

puts "Seeded users:"
puts "  casting@example.com / password123"
puts "  actor@example.com   / password123"
puts "  agent@example.com   / password123"
