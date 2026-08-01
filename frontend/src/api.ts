export type User = {
  id: string
  email: string
  first_name: string
  last_name: string
  full_name: string
  phone_number: string | null
  status: string
  personas: {
    actor: boolean
    casting_professional: boolean
    representative: boolean
    representative_type: string | null
  }
  actor_profile_id: string | null
  casting_professional_profile_id: string | null
  representative_profile_id: string | null
}

export type ActorProfile = {
  id: string
  professional_name: string | null
  union_status: string | null
  primary_location: string | null
  timezone: string | null
  profile_status: string
  display_name: string
}

export type CastingProfessionalProfile = {
  id: string
  professional_title: string | null
}

export type RepresentativeProfile = {
  id: string
  representative_type: string
}

export type Organization = {
  id: string
  name: string
  organization_type: string
  status: string
  website_url: string | null
  phone_number: string | null
  email: string | null
  city: string | null
  state_region: string | null
  country_code: string | null
  address_line_1?: string | null
  address_line_2?: string | null
  postal_code?: string | null
  current_membership?: OrganizationMembership | null
}

export type OrganizationMembership = {
  id: string
  organization_id: string
  user_id: string
  user_email: string
  user_full_name: string
  membership_role: string
  job_title: string | null
  status: string
  started_on: string | null
  ended_on: string | null
  invited_at: string | null
  accepted_at: string | null
  organization?: Organization
}

export type Division = {
  id: string
  organization_id: string
  name: string
  slug: string
  description: string | null
  active: boolean
}

export type Breakdown = {
  id: string
  project_id: string
  project_name: string
  character_name: string
  description: string
  role_type: string | null
  billing: string | null
  status: string
  visibility: string
  number_of_roles: number
  audition_required: boolean
  submission_deadline: string | null
  work_start_date: string | null
  work_end_date: string | null
  compensation_details: string | null
  location_details: string | null
  published_at: string | null
  criteria: {
    portrayal_age_min: number | null
    portrayal_age_max: number | null
    gender_presentation: string | null
    union_requirement: string | null
    local_hire_required: boolean
    required_location: string | null
    travel_provided: boolean | null
    work_authorization: string | null
  } | null
  skill_requirements: Array<{
    id: string
    skill_id: string
    skill_name: string
    requirement_level: string
    minimum_proficiency: string | null
    notes: string | null
  }>
}

export type Project = {
  id: string
  name: string
  project_type: string
  description: string | null
  status: string
  casting_office_id: string | null
  casting_office_name: string | null
  created_by_user_id: string
  production_company_name: string | null
  union_status: string | null
  shoot_start_date: string | null
  shoot_end_date: string | null
  location_summary: string | null
  confidential: boolean
  published_at: string | null
  created_at: string
  breakdowns?: Breakdown[]
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers)
  if (options.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const response = await fetch(path, {
    ...options,
    headers,
    credentials: 'include',
  })

  if (response.status === 204) {
    return undefined as T
  }

  const data = await response.json().catch(() => ({}))

  if (!response.ok) {
    const message =
      data.error ||
      (Array.isArray(data.errors) ? data.errors.join(', ') : null) ||
      'Request failed'
    throw new Error(message)
  }

  return data as T
}

export const api = {
  getSession: () => request<{ user: User }>('/api/v1/session'),
  updateSession: (user: {
    first_name?: string
    last_name?: string
    phone_number?: string | null
    current_password?: string
    password?: string
    password_confirmation?: string
  }) =>
    request<{ user: User }>('/api/v1/session', {
      method: 'PATCH',
      body: JSON.stringify({ user }),
    }),
  getActorProfile: () => request<{ actor_profile: ActorProfile }>('/api/v1/actor_profile'),
  updateActorProfile: (actor_profile: Partial<ActorProfile>) =>
    request<{ actor_profile: ActorProfile }>('/api/v1/actor_profile', {
      method: 'PATCH',
      body: JSON.stringify({ actor_profile }),
    }),
  getCastingProfessionalProfile: () =>
    request<{ casting_professional_profile: CastingProfessionalProfile }>(
      '/api/v1/casting_professional_profile',
    ),
  updateCastingProfessionalProfile: (casting_professional_profile: Partial<CastingProfessionalProfile>) =>
    request<{ casting_professional_profile: CastingProfessionalProfile }>(
      '/api/v1/casting_professional_profile',
      {
        method: 'PATCH',
        body: JSON.stringify({ casting_professional_profile }),
      },
    ),
  getRepresentativeProfile: () =>
    request<{ representative_profile: RepresentativeProfile }>('/api/v1/representative_profile'),
  login: (email: string, password: string) =>
    request<{ user: User }>('/api/v1/session', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    }),
  logout: () => request<void>('/api/v1/session', { method: 'DELETE' }),
  register: (payload: {
    user: {
      email: string
      password: string
      password_confirmation: string
      first_name: string
      last_name: string
    }
    personas: string[]
  }) =>
    request<{ user: User }>('/api/v1/registrations', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
  listOrganizations: () =>
    request<{ organizations: Organization[] }>('/api/v1/organizations'),
  getOrganization: (id: string) =>
    request<{ organization: Organization }>(`/api/v1/organizations/${id}`),
  createOrganization: (organization: Partial<Organization>) =>
    request<{ organization: Organization }>('/api/v1/organizations', {
      method: 'POST',
      body: JSON.stringify({ organization }),
    }),
  deleteOrganization: (id: string) =>
    request<void>(`/api/v1/organizations/${id}`, { method: 'DELETE' }),
  listMyMemberships: () =>
    request<{ memberships: OrganizationMembership[] }>('/api/v1/me/memberships'),
  listOrganizationMemberships: (organizationId: string) =>
    request<{ memberships: OrganizationMembership[] }>(
      `/api/v1/organizations/${organizationId}/memberships`,
    ),
  createOrganizationMembership: (
    organizationId: string,
    membership: Partial<OrganizationMembership> & { email?: string },
  ) =>
    request<{ membership: OrganizationMembership }>(
      `/api/v1/organizations/${organizationId}/memberships`,
      {
        method: 'POST',
        body: JSON.stringify({ membership }),
      },
    ),
  updateOrganizationMembership: (
    organizationId: string,
    membershipId: string,
    membership: Partial<OrganizationMembership>,
  ) =>
    request<{ membership: OrganizationMembership }>(
      `/api/v1/organizations/${organizationId}/memberships/${membershipId}`,
      {
        method: 'PATCH',
        body: JSON.stringify({ membership }),
      },
    ),
  deleteOrganizationMembership: (organizationId: string, membershipId: string) =>
    request<void>(`/api/v1/organizations/${organizationId}/memberships/${membershipId}`, {
      method: 'DELETE',
    }),
  listDivisions: (organizationId: string) =>
    request<{ divisions: Division[] }>(`/api/v1/organizations/${organizationId}/divisions`),
  createDivision: (organizationId: string, division: Partial<Division>) =>
    request<{ division: Division }>(`/api/v1/organizations/${organizationId}/divisions`, {
      method: 'POST',
      body: JSON.stringify({ division }),
    }),
  updateDivision: (organizationId: string, divisionId: string, division: Partial<Division>) =>
    request<{ division: Division }>(
      `/api/v1/organizations/${organizationId}/divisions/${divisionId}`,
      {
        method: 'PATCH',
        body: JSON.stringify({ division }),
      },
    ),
  deleteDivision: (organizationId: string, divisionId: string) =>
    request<void>(`/api/v1/organizations/${organizationId}/divisions/${divisionId}`, {
      method: 'DELETE',
    }),
  listProjects: () => request<{ projects: Project[] }>('/api/v1/projects'),
  getProject: (id: string) => request<{ project: Project }>(`/api/v1/projects/${id}`),
  createProject: (project: Partial<Project>) =>
    request<{ project: Project }>('/api/v1/projects', {
      method: 'POST',
      body: JSON.stringify({ project }),
    }),
  listBreakdowns: () => request<{ breakdowns: Breakdown[] }>('/api/v1/breakdowns'),
  getBreakdown: (id: string) =>
    request<{ breakdown: Breakdown }>(`/api/v1/breakdowns/${id}`),
  createBreakdown: (
    projectId: string,
    payload: {
      breakdown: Partial<Breakdown>
      criteria?: Breakdown['criteria']
      skill_requirements?: Array<{
        skill_id: string
        requirement_level?: string
        minimum_proficiency?: string
      }>
    },
  ) =>
    request<{ breakdown: Breakdown }>(`/api/v1/projects/${projectId}/breakdowns`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
  listSkills: () =>
    request<{ skills: Array<{ id: string; name: string; category: string | null; slug: string }> }>(
      '/api/v1/skills',
    ),
}
