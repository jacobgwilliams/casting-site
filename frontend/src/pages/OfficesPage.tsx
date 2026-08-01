import { useEffect, useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { api, type OrganizationMembership } from '../api'
import { useAuth } from '../auth'
import { defaultPersonaPath } from '../personas'
import { PersonaNav } from '../components/PersonaNav'

const OFFICE_TYPE_LABELS: Record<string, string> = {
  casting_office: 'Casting office',
  agency: 'Agency',
  management_company: 'Management company',
}

function defaultOfficeType(user: ReturnType<typeof useAuth>['user']) {
  if (user?.personas.casting_professional) return 'casting_office'
  if (user?.personas.representative_type === 'manager') return 'management_company'
  if (user?.personas.representative) return 'agency'
  return 'casting_office'
}

export function OfficesPage() {
  const { user, logout } = useAuth()
  const [memberships, setMemberships] = useState<OrganizationMembership[]>([])
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [creating, setCreating] = useState(false)
  const [officeForm, setOfficeForm] = useState({
    name: '',
    organization_type: 'casting_office',
    city: '',
    state_region: '',
    country_code: 'US',
  })

  useEffect(() => {
    if (!user) return
    setOfficeForm((current) => ({
      ...current,
      organization_type: defaultOfficeType(user),
    }))
    void load()
  }, [user])

  async function load() {
    try {
      const data = await api.listMyMemberships()
      setMemberships(data.memberships)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load memberships')
    }
  }

  async function onCreateOffice(event: FormEvent) {
    event.preventDefault()
    setCreating(true)
    setError(null)
    setSuccess(null)
    try {
      const data = await api.createOrganization(officeForm)
      setSuccess(`Created ${data.organization.name}.`)
      setOfficeForm((current) => ({ ...current, name: '', city: '', state_region: '' }))
      await load()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not create office')
    } finally {
      setCreating(false)
    }
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">Offices</p>
        </div>
        <div className="topbar-actions">
          <PersonaNav />
          <Link to={user ? defaultPersonaPath(user) : '/'} className="ghost button-link">
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

      <main className="workspace single">
        <section>
          <div className="section-head">
            <h1>Your offices</h1>
            <p>
              Casting professionals join casting offices. Agents and managers join agency or
              management company offices.
            </p>
          </div>
          <div className="list">
            {memberships.length === 0 && (
              <p className="muted">You are not a member of any offices yet.</p>
            )}
            {memberships.map((membership) => (
              <Link
                key={membership.id}
                to={`/offices/${membership.organization_id}`}
                className="list-item"
              >
                <div>
                  <strong>{membership.organization?.name ?? 'Office'}</strong>
                  <span className="muted">
                    {' '}
                    · {OFFICE_TYPE_LABELS[membership.organization?.organization_type ?? ''] ??
                      membership.organization?.organization_type}
                    {' '}
                    · {membership.membership_role.replaceAll('_', ' ')}
                  </span>
                </div>
                <span className="pill">{membership.status}</span>
              </Link>
            ))}
          </div>
        </section>

        <section>
          <form className="panel stack" onSubmit={onCreateOffice}>
            <div className="section-head">
              <h2>Create office</h2>
              <p>You will be added as the owner.</p>
            </div>
            <label>
              Name
              <input
                value={officeForm.name}
                onChange={(e) => setOfficeForm({ ...officeForm, name: e.target.value })}
                required
              />
            </label>
            <label>
              Type
              <select
                value={officeForm.organization_type}
                onChange={(e) => setOfficeForm({ ...officeForm, organization_type: e.target.value })}
              >
                <option value="casting_office">Casting office</option>
                <option value="agency">Agency</option>
                <option value="management_company">Management company</option>
              </select>
            </label>
            <div className="row">
              <label>
                City
                <input
                  value={officeForm.city}
                  onChange={(e) => setOfficeForm({ ...officeForm, city: e.target.value })}
                />
              </label>
              <label>
                State / region
                <input
                  value={officeForm.state_region}
                  onChange={(e) => setOfficeForm({ ...officeForm, state_region: e.target.value })}
                />
              </label>
            </div>
            <button type="submit" disabled={creating}>
              {creating ? 'Creating…' : 'Create office'}
            </button>
          </form>
        </section>
      </main>
    </div>
  )
}
