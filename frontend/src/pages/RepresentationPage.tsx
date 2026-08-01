import { useEffect, useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { api, type ActorRepresentation, type Organization } from '../api'
import { useAuth } from '../auth'

export function RepresentationPage() {
  const { user, logout } = useAuth()
  const [representations, setRepresentations] = useState<ActorRepresentation[]>([])
  const [agencies, setAgencies] = useState<Organization[]>([])
  const [organizationId, setOrganizationId] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    void load()
  }, [])

  async function load() {
    setLoading(true)
    setError(null)
    try {
      const [repsRes, orgsRes] = await Promise.all([
        api.listActorRepresentations(),
        api.listOrganizations(),
      ])
      setRepresentations(repsRes.actor_representations)
      const agencyList = orgsRes.organizations.filter((org) =>
        ['agency', 'management_company'].includes(org.organization_type),
      )
      setAgencies(agencyList)
      if (agencyList.length > 0 && !organizationId) {
        setOrganizationId(agencyList[0].id)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load representation')
    } finally {
      setLoading(false)
    }
  }

  async function onRequest(event: FormEvent) {
    event.preventDefault()
    if (!organizationId) return

    setSubmitting(true)
    setError(null)
    setSuccess(null)
    try {
      await api.createActorRepresentation({ organization_id: organizationId })
      setSuccess('Representation request sent.')
      await load()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not request representation')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">My representation</p>
        </div>
        <div className="topbar-actions">
          <Link to="/" className="ghost button-link">
            Home
          </Link>
          <Link to="/account" className="ghost button-link">
            My account
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
            <h1>Agencies & management</h1>
            <p>
              {user?.full_name
                ? `${user.full_name}, these are your representation relationships.`
                : 'Your representation relationships.'}
            </p>
          </div>

          {loading ? (
            <p className="muted">Loading…</p>
          ) : (
            <div className="list">
              {representations.length === 0 && (
                <p className="muted">You are not linked to any agencies yet.</p>
              )}
              {representations.map((representation) => (
                <article key={representation.id} className="list-item panel stack">
                  <div>
                    <strong>{representation.organization_name}</strong>
                    <span className="muted">
                      {' '}
                      · {representation.organization_type.replaceAll('_', ' ')}
                    </span>
                  </div>
                  <span className="pill">{representation.status}</span>
                  {representation.divisions.length > 0 && (
                    <p className="muted">
                      Divisions:{' '}
                      {representation.divisions.map((division) => division.division_name).join(', ')}
                    </p>
                  )}
                </article>
              ))}
            </div>
          )}
        </section>

        <section>
          <form className="panel stack" onSubmit={onRequest}>
            <div className="section-head">
              <h2>Request representation</h2>
              <p>Ask to join an agency or management company.</p>
            </div>
            <label>
              Organization
              <select
                value={organizationId}
                onChange={(e) => setOrganizationId(e.target.value)}
                required
              >
                <option value="">Select…</option>
                {agencies.map((agency) => (
                  <option key={agency.id} value={agency.id}>
                    {agency.name}
                  </option>
                ))}
              </select>
            </label>
            <button type="submit" disabled={submitting || !organizationId}>
              {submitting ? 'Sending…' : 'Send request'}
            </button>
          </form>
        </section>
      </main>
    </div>
  )
}
