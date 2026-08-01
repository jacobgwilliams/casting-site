import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import {
  api,
  type ActorRepresentation,
  type Division,
  type OrganizationMembership,
} from '../api'
import { useAuth } from '../auth'

export function RosterPage() {
  const { user, logout } = useAuth()
  const [memberships, setMemberships] = useState<OrganizationMembership[]>([])
  const [organizationId, setOrganizationId] = useState('')
  const [representations, setRepresentations] = useState<ActorRepresentation[]>([])
  const [divisions, setDivisions] = useState<Division[]>([])
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [savingId, setSavingId] = useState<string | null>(null)

  const repMemberships = memberships.filter((membership) =>
    ['agency', 'management_company'].includes(membership.organization?.organization_type ?? ''),
  )

  useEffect(() => {
    void loadMemberships()
  }, [])

  useEffect(() => {
    if (!organizationId) return
    void loadRoster(organizationId)
  }, [organizationId])

  async function loadMemberships() {
    setLoading(true)
    setError(null)
    try {
      const data = await api.listMyMemberships()
      setMemberships(data.memberships)
      const reps = data.memberships.filter((membership) =>
        ['agency', 'management_company'].includes(
          membership.organization?.organization_type ?? '',
        ),
      )
      if (reps.length > 0) {
        setOrganizationId(reps[0].organization_id)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load memberships')
    } finally {
      setLoading(false)
    }
  }

  async function loadRoster(orgId: string) {
    setError(null)
    try {
      const [repsRes, divisionsRes] = await Promise.all([
        api.listActorRepresentations(orgId),
        api.listDivisions(orgId),
      ])
      setRepresentations(repsRes.actor_representations)
      setDivisions(divisionsRes.divisions.filter((division) => division.active))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load roster')
    }
  }

  async function activateRepresentation(representation: ActorRepresentation) {
    setSavingId(representation.id)
    setError(null)
    setSuccess(null)
    try {
      await api.updateActorRepresentation(representation.id, { status: 'active' })
      setSuccess(`Activated ${representation.actor_name}.`)
      await loadRoster(organizationId)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not activate representation')
    } finally {
      setSavingId(null)
    }
  }

  async function assignDivision(representation: ActorRepresentation, divisionId: string) {
    if (!divisionId) return

    setSavingId(representation.id)
    setError(null)
    setSuccess(null)
    try {
      await api.createRepresentationDivision(representation.id, { division_id: divisionId })
      setSuccess(`Assigned division for ${representation.actor_name}.`)
      await loadRoster(organizationId)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not assign division')
    } finally {
      setSavingId(null)
    }
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">My roster</p>
        </div>
        <div className="topbar-actions">
          <Link to="/" className="ghost button-link">
            Home
          </Link>
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

      <main className="workspace">
        <section>
          <div className="section-head">
            <h1>Represented actors</h1>
            <p>
              {user?.full_name
                ? `${user.full_name}, manage clients at your agency.`
                : 'Manage clients at your agency.'}
            </p>
          </div>

          {loading ? (
            <p className="muted">Loading…</p>
          ) : repMemberships.length === 0 ? (
            <p className="muted">Join an agency or management company to see a roster.</p>
          ) : (
            <>
              <label className="panel stack">
                Agency
                <select
                  value={organizationId}
                  onChange={(e) => setOrganizationId(e.target.value)}
                >
                  {repMemberships.map((membership) => (
                    <option key={membership.id} value={membership.organization_id}>
                      {membership.organization?.name ?? membership.organization_id}
                    </option>
                  ))}
                </select>
              </label>

              <div className="list">
                {representations.length === 0 && (
                  <p className="muted">No represented actors for this office yet.</p>
                )}
                {representations.map((representation) => {
                  const assignedDivisionIds = new Set(
                    representation.divisions.map((division) => division.division_id),
                  )
                  const availableDivisions = divisions.filter(
                    (division) => !assignedDivisionIds.has(division.id),
                  )

                  return (
                    <article key={representation.id} className="list-item panel stack">
                      <div>
                        <strong>{representation.actor_name}</strong>
                        <span className="muted"> · {representation.status}</span>
                      </div>

                      {representation.status === 'pending' && (
                        <button
                          type="button"
                          disabled={savingId === representation.id}
                          onClick={() => void activateRepresentation(representation)}
                        >
                          {savingId === representation.id ? 'Saving…' : 'Confirm representation'}
                        </button>
                      )}

                      {representation.divisions.length > 0 && (
                        <p className="muted">
                          Divisions:{' '}
                          {representation.divisions
                            .map((division) => division.division_name)
                            .join(', ')}
                        </p>
                      )}

                      {representation.status === 'active' && availableDivisions.length > 0 && (
                        <label>
                          Assign division
                          <select
                            defaultValue=""
                            disabled={savingId === representation.id}
                            onChange={(e) => {
                              const divisionId = e.target.value
                              e.target.value = ''
                              void assignDivision(representation, divisionId)
                            }}
                          >
                            <option value="">Select division…</option>
                            {availableDivisions.map((division) => (
                              <option key={division.id} value={division.id}>
                                {division.name}
                              </option>
                            ))}
                          </select>
                        </label>
                      )}
                    </article>
                  )
                })}
              </div>
            </>
          )}
        </section>
      </main>
    </div>
  )
}
