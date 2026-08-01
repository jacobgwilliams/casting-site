import { useEffect, useState, type FormEvent } from 'react'
import { Link, useParams } from 'react-router-dom'
import { api, type Division, type Organization, type OrganizationMembership } from '../api'
import { useAuth } from '../auth'

const OFFICE_TYPE_LABELS: Record<string, string> = {
  casting_office: 'Casting office',
  agency: 'Agency',
  management_company: 'Management company',
}

type Tab = 'members' | 'divisions'

function roleOptions(officeType: string) {
  switch (officeType) {
    case 'casting_office':
      return [
        { value: 'casting_director', label: 'Casting director' },
        { value: 'casting_associate', label: 'Casting associate' },
        { value: 'casting_assistant', label: 'Casting assistant' },
        { value: 'staff', label: 'Staff' },
      ]
    case 'agency':
      return [
        { value: 'agent', label: 'Agent' },
        { value: 'staff', label: 'Staff' },
      ]
    case 'management_company':
      return [
        { value: 'manager', label: 'Manager' },
        { value: 'staff', label: 'Staff' },
      ]
    default:
      return [{ value: 'staff', label: 'Staff' }]
  }
}

function supportsDivisions(officeType: string) {
  return officeType === 'agency' || officeType === 'management_company'
}

export function OfficePage() {
  const { id } = useParams<{ id: string }>()
  const { user, logout } = useAuth()
  const [office, setOffice] = useState<Organization | null>(null)
  const [memberships, setMemberships] = useState<OrganizationMembership[]>([])
  const [divisions, setDivisions] = useState<Division[]>([])
  const [tab, setTab] = useState<Tab>('members')
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)
  const [inviteForm, setInviteForm] = useState({
    email: '',
    membership_role: 'staff',
    status: 'invited',
  })
  const [divisionForm, setDivisionForm] = useState({
    name: '',
    slug: '',
    description: '',
    active: true,
  })

  const currentMembership = office?.current_membership
  const isAdmin =
    currentMembership?.membership_role === 'owner' ||
    currentMembership?.membership_role === 'administrator'
  const hasDivisions = office ? supportsDivisions(office.organization_type) : false

  useEffect(() => {
    if (!id) return
    void load(id)
  }, [id])

  async function load(officeId: string) {
    setError(null)
    try {
      const officeRes = await api.getOrganization(officeId)
      const requests: [
        Promise<{ memberships: OrganizationMembership[] }>,
        Promise<{ divisions: Division[] }> | Promise<{ divisions: [] }>,
      ] = [
        api.listOrganizationMemberships(officeId).catch(() => ({ memberships: [] })),
        supportsDivisions(officeRes.organization.organization_type)
          ? api.listDivisions(officeId).catch(() => ({ divisions: [] }))
          : Promise.resolve({ divisions: [] }),
      ]
      const [membershipsRes, divisionsRes] = await Promise.all(requests)
      setOffice(officeRes.organization)
      setMemberships(membershipsRes.memberships)
      setDivisions(divisionsRes.divisions)
      const roles = roleOptions(officeRes.organization.organization_type)
      setInviteForm((current) => ({
        ...current,
        membership_role: roles[0]?.value ?? 'staff',
      }))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load office')
    }
  }

  async function onInviteMember(event: FormEvent) {
    event.preventDefault()
    if (!id) return
    setSaving(true)
    setError(null)
    setSuccess(null)
    try {
      await api.createOrganizationMembership(id, inviteForm)
      setInviteForm((current) => ({ ...current, email: '' }))
      setSuccess('Member invited.')
      await load(id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not add member')
    } finally {
      setSaving(false)
    }
  }

  async function onCreateDivision(event: FormEvent) {
    event.preventDefault()
    if (!id) return
    setSaving(true)
    setError(null)
    setSuccess(null)
    try {
      await api.createDivision(id, {
        name: divisionForm.name,
        slug: divisionForm.slug || undefined,
        description: divisionForm.description || null,
        active: divisionForm.active,
      })
      setDivisionForm({ name: '', slug: '', description: '', active: true })
      setSuccess('Division created.')
      await load(id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not create division')
    } finally {
      setSaving(false)
    }
  }

  async function onToggleDivisionActive(division: Division) {
    if (!id) return
    setSaving(true)
    setError(null)
    try {
      await api.updateDivision(id, division.id, { active: !division.active })
      setSuccess('Division updated.')
      await load(id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not update division')
    } finally {
      setSaving(false)
    }
  }

  async function onDeleteDivision(divisionId: string) {
    if (!id) return
    setSaving(true)
    setError(null)
    try {
      await api.deleteDivision(id, divisionId)
      setSuccess('Division deleted.')
      await load(id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not delete division')
    } finally {
      setSaving(false)
    }
  }

  async function onAcceptInvite(membershipId: string) {
    if (!id) return
    setSaving(true)
    setError(null)
    try {
      await api.updateOrganizationMembership(id, membershipId, { status: 'active' })
      setSuccess('Membership accepted.')
      await load(id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not accept invitation')
    } finally {
      setSaving(false)
    }
  }

  async function onRemoveMember(membershipId: string) {
    if (!id) return
    setSaving(true)
    setError(null)
    try {
      await api.deleteOrganizationMembership(id, membershipId)
      setSuccess('Membership removed.')
      await load(id)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not remove member')
    } finally {
      setSaving(false)
    }
  }

  if (!office) {
    return (
      <div className="app-shell">
        <p className="loading">{error ?? 'Loading…'}</p>
      </div>
    )
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">{office.name}</p>
        </div>
        <div className="topbar-actions">
          <Link to="/offices" className="ghost button-link">
            Offices
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      {error && <p className="error banner">{error}</p>}
      {success && <p className="success banner">{success}</p>}

      <main className="detail account-page">
        <section className="panel stack">
          <div className="section-head">
            <h1>{office.name}</h1>
            <p>
              {OFFICE_TYPE_LABELS[office.organization_type] ?? office.organization_type}
              {office.city ? ` · ${office.city}` : ''}
              {office.state_region ? `, ${office.state_region}` : ''}
            </p>
          </div>
          {currentMembership && (
            <p className="muted">
              Your role: {currentMembership.membership_role.replaceAll('_', ' ')} (
              {currentMembership.status})
            </p>
          )}
          {currentMembership?.status === 'invited' && (
            <button type="button" onClick={() => void onAcceptInvite(currentMembership.id)} disabled={saving}>
              Accept invitation
            </button>
          )}
        </section>

        <nav className="tab-bar" aria-label="Office sections">
          <button
            type="button"
            className={tab === 'members' ? 'tab active' : 'tab'}
            onClick={() => setTab('members')}
          >
            Members
          </button>
          {hasDivisions && (
            <button
              type="button"
              className={tab === 'divisions' ? 'tab active' : 'tab'}
              onClick={() => setTab('divisions')}
            >
              Divisions
            </button>
          )}
        </nav>

        {tab === 'members' && (
          <>
            <section>
              <div className="section-head">
                <h2>Members</h2>
              </div>
              <div className="list">
                {memberships.map((membership) => (
                  <div key={membership.id} className="list-item">
                    <div>
                      <strong>{membership.user_full_name}</strong>
                      <span className="muted">
                        {' '}
                        · {membership.user_email} · {membership.membership_role.replaceAll('_', ' ')}
                      </span>
                    </div>
                    <div className="inline-actions">
                      <span className="pill">{membership.status}</span>
                      {membership.status === 'invited' && membership.user_id === user?.id && (
                        <button type="button" className="ghost" onClick={() => void onAcceptInvite(membership.id)}>
                          Accept
                        </button>
                      )}
                      {isAdmin && membership.membership_role !== 'owner' && membership.status !== 'removed' && (
                        <button type="button" className="ghost" onClick={() => void onRemoveMember(membership.id)}>
                          Remove
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>

            {isAdmin && (
              <form className="panel stack" onSubmit={onInviteMember}>
                <div className="section-head">
                  <h2>Invite member</h2>
                  <p>Add someone by email. They must already have an account.</p>
                </div>
                <label>
                  Email
                  <input
                    type="email"
                    value={inviteForm.email}
                    onChange={(e) => setInviteForm({ ...inviteForm, email: e.target.value })}
                    required
                  />
                </label>
                <label>
                  Role
                  <select
                    value={inviteForm.membership_role}
                    onChange={(e) => setInviteForm({ ...inviteForm, membership_role: e.target.value })}
                  >
                    {roleOptions(office.organization_type).map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </label>
                <button type="submit" disabled={saving}>
                  {saving ? 'Saving…' : 'Send invitation'}
                </button>
              </form>
            )}

            {!isAdmin && !currentMembership && (
              <form
                className="panel stack"
                onSubmit={async (event) => {
                  event.preventDefault()
                  if (!id || !user) return
                  setSaving(true)
                  setError(null)
                  try {
                    const roles = roleOptions(office.organization_type)
                    await api.createOrganizationMembership(id, {
                      membership_role: roles[0]?.value ?? 'staff',
                      status: 'invited',
                    })
                    setSuccess('Join request sent.')
                    await load(id)
                  } catch (err) {
                    setError(err instanceof Error ? err.message : 'Could not request to join')
                  } finally {
                    setSaving(false)
                  }
                }}
              >
                <div className="section-head">
                  <h2>Request to join</h2>
                  <p>An office admin will need to approve your membership.</p>
                </div>
                <button type="submit" disabled={saving}>
                  {saving ? 'Saving…' : 'Request to join'}
                </button>
              </form>
            )}
          </>
        )}

        {tab === 'divisions' && hasDivisions && (
          <>
            <section>
              <div className="section-head">
                <h2>Divisions</h2>
                <p>How this office organizes its roster — commercial, film &amp; TV, and so on.</p>
              </div>
              <div className="list">
                {divisions.length === 0 && <p className="muted">No divisions yet.</p>}
                {divisions.map((division) => (
                  <div key={division.id} className="list-item">
                    <div>
                      <strong>{division.name}</strong>
                      <span className="muted"> · {division.slug}</span>
                      {division.description && <p className="muted">{division.description}</p>}
                    </div>
                    <div className="inline-actions">
                      <span className="pill">{division.active ? 'Active' : 'Inactive'}</span>
                      {isAdmin && (
                        <>
                          <button
                            type="button"
                            className="ghost"
                            onClick={() => void onToggleDivisionActive(division)}
                            disabled={saving}
                          >
                            {division.active ? 'Deactivate' : 'Activate'}
                          </button>
                          <button
                            type="button"
                            className="ghost"
                            onClick={() => void onDeleteDivision(division.id)}
                            disabled={saving}
                          >
                            Delete
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>

            {isAdmin && (
              <form className="panel stack" onSubmit={onCreateDivision}>
                <div className="section-head">
                  <h2>New division</h2>
                </div>
                <label>
                  Name
                  <input
                    value={divisionForm.name}
                    onChange={(e) => setDivisionForm({ ...divisionForm, name: e.target.value })}
                    placeholder="e.g. Commercial"
                    required
                  />
                </label>
                <label>
                  Slug
                  <input
                    value={divisionForm.slug}
                    onChange={(e) => setDivisionForm({ ...divisionForm, slug: e.target.value })}
                    placeholder="Optional — generated from name if blank"
                  />
                </label>
                <label>
                  Description
                  <textarea
                    value={divisionForm.description}
                    onChange={(e) => setDivisionForm({ ...divisionForm, description: e.target.value })}
                    rows={2}
                  />
                </label>
                <label className="check">
                  <input
                    type="checkbox"
                    checked={divisionForm.active}
                    onChange={(e) => setDivisionForm({ ...divisionForm, active: e.target.checked })}
                  />
                  Active
                </label>
                <button type="submit" disabled={saving}>
                  {saving ? 'Saving…' : 'Create division'}
                </button>
              </form>
            )}
          </>
        )}
      </main>
    </div>
  )
}
