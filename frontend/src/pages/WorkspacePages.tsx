import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api, type Breakdown, type Project } from '../api'
import { useAuth } from '../auth'
import { PersonaNav } from '../components/PersonaNav'

type WorkspaceProps = {
  persona: 'casting' | 'actor' | 'rep'
  title: string
  showProjectCreate?: boolean
}

export function WorkspaceBreakdownsPage({ persona, title }: Pick<WorkspaceProps, 'persona' | 'title'>) {
  const { user, logout } = useAuth()
  const [breakdowns, setBreakdowns] = useState<Breakdown[]>([])
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    void api.listBreakdowns().then((data) => setBreakdowns(data.breakdowns)).catch((err) => {
      setError(err instanceof Error ? err.message : 'Failed to load breakdowns')
    })
  }, [])

  const homePath = persona === 'casting' ? '/casting' : persona === 'actor' ? '/actor' : '/rep'

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">{title}</p>
        </div>
        <div className="topbar-actions">
          <PersonaNav current={persona} />
          <Link to={homePath} className="ghost button-link">
            Home
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      {error && <p className="error banner">{error}</p>}

      <main className="workspace">
        <section>
          <div className="section-head">
            <h1>Visible breakdowns</h1>
            <p>Signed in as {user?.full_name}</p>
          </div>
          <div className="list">
            {breakdowns.length === 0 && <p className="muted">No breakdowns visible to you yet.</p>}
            {breakdowns.map((breakdown) => (
              <Link key={breakdown.id} to={`/breakdowns/${breakdown.id}`} className="list-item">
                <div>
                  <strong>{breakdown.character_name}</strong>
                  <span className="muted"> · {breakdown.project_name}</span>
                </div>
                <span className={`pill visibility-${breakdown.visibility}`}>
                  {breakdown.visibility.replaceAll('_', ' ')}
                </span>
              </Link>
            ))}
          </div>
        </section>
      </main>
    </div>
  )
}

export function WorkspaceProjectsPage({ persona, title, showProjectCreate = false }: WorkspaceProps) {
  const { user, logout } = useAuth()
  const [projects, setProjects] = useState<Project[]>([])
  const [organizations, setOrganizations] = useState<Awaited<ReturnType<typeof api.listOrganizations>>['organizations']>([])
  const [error, setError] = useState<string | null>(null)
  const [creating, setCreating] = useState(false)
  const [projectForm, setProjectForm] = useState({
    name: '',
    project_type: 'commercial',
    description: '',
    casting_office_id: '',
  })

  const homePath = '/casting'

  useEffect(() => {
    void load()
  }, [])

  async function load() {
    try {
      const [projectsRes, orgsRes] = await Promise.all([api.listProjects(), api.listOrganizations()])
      setProjects(projectsRes.projects)
      setOrganizations(orgsRes.organizations)
      const office = orgsRes.organizations.find((org) => org.organization_type === 'casting_office')
      if (office) {
        setProjectForm((current) => ({
          ...current,
          casting_office_id: current.casting_office_id || office.id,
        }))
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load projects')
    }
  }

  async function onCreateProject(event: React.FormEvent) {
    event.preventDefault()
    setCreating(true)
    setError(null)
    try {
      await api.createProject({
        ...projectForm,
        casting_office_id: projectForm.casting_office_id || null,
        published_at: new Date().toISOString(),
      })
      setProjectForm((current) => ({ ...current, name: '', description: '' }))
      await load()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not create project')
    } finally {
      setCreating(false)
    }
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">{title}</p>
        </div>
        <div className="topbar-actions">
          <PersonaNav current={persona} />
          <Link to={homePath} className="ghost button-link">
            Home
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      {error && <p className="error banner">{error}</p>}

      <main className="workspace">
        <section>
          <div className="section-head">
            <h1>Projects</h1>
            <p>Casting offices create projects, then attach breakdowns.</p>
          </div>
          <div className="list">
            {projects.map((project) => (
              <Link key={project.id} to={`/projects/${project.id}`} className="list-item">
                <div>
                  <strong>{project.name}</strong>
                  <span className="muted">
                    {' '}
                    · {project.project_type.replaceAll('_', ' ')}
                    {project.casting_office_name ? ` · ${project.casting_office_name}` : ''}
                  </span>
                </div>
                <span className="pill">{project.status}</span>
              </Link>
            ))}
          </div>

          {showProjectCreate && user?.personas.casting_professional && (
            <form className="panel stack" onSubmit={onCreateProject}>
              <h3>New project</h3>
              <label>
                Name
                <input
                  value={projectForm.name}
                  onChange={(e) => setProjectForm({ ...projectForm, name: e.target.value })}
                  required
                />
              </label>
              <label>
                Type
                <select
                  value={projectForm.project_type}
                  onChange={(e) => setProjectForm({ ...projectForm, project_type: e.target.value })}
                >
                  <option value="commercial">Commercial</option>
                  <option value="feature_film">Feature film</option>
                  <option value="television">Television</option>
                  <option value="theater">Theater</option>
                  <option value="voice_over">Voice over</option>
                </select>
              </label>
              <label>
                Casting office
                <select
                  value={projectForm.casting_office_id}
                  onChange={(e) =>
                    setProjectForm({ ...projectForm, casting_office_id: e.target.value })
                  }
                >
                  <option value="">None</option>
                  {organizations
                    .filter((org) => org.organization_type === 'casting_office')
                    .map((org) => (
                      <option key={org.id} value={org.id}>
                        {org.name}
                      </option>
                    ))}
                </select>
              </label>
              <label>
                Description
                <textarea
                  value={projectForm.description}
                  onChange={(e) => setProjectForm({ ...projectForm, description: e.target.value })}
                  rows={3}
                />
              </label>
              <button type="submit" disabled={creating}>
                {creating ? 'Creating…' : 'Create project'}
              </button>
            </form>
          )}
        </section>
      </main>
    </div>
  )
}
