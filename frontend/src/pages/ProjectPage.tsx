import { useEffect, useState, type FormEvent } from 'react'
import { Link, useParams } from 'react-router-dom'
import { api, type Project } from '../api'
import { useAuth } from '../auth'
import { defaultPersonaPath } from '../personas'

export function ProjectPage() {
  const { id } = useParams<{ id: string }>()
  const { user } = useAuth()
  const homePath = user ? defaultPersonaPath(user) : '/'
  const [project, setProject] = useState<Project | null>(null)
  const [skills, setSkills] = useState<Array<{ id: string; name: string }>>([])
  const [error, setError] = useState<string | null>(null)
  const [form, setForm] = useState({
    character_name: '',
    description: '',
    visibility: 'public',
    status: 'published',
    portrayal_age_min: '20',
    portrayal_age_max: '40',
    union_requirement: 'SAG-AFTRA',
    skill_id: '',
    requirement_level: 'preferred',
  })
  const [creating, setCreating] = useState(false)

  useEffect(() => {
    if (!id) return
    void (async () => {
      try {
        const [projectRes, skillsRes] = await Promise.all([api.getProject(id), api.listSkills()])
        setProject(projectRes.project)
        setSkills(skillsRes.skills)
        if (skillsRes.skills[0]) {
          setForm((current) => ({ ...current, skill_id: current.skill_id || skillsRes.skills[0].id }))
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load project')
      }
    })()
  }, [id])

  async function onCreateBreakdown(event: FormEvent) {
    event.preventDefault()
    if (!id) return
    setCreating(true)
    setError(null)
    try {
      await api.createBreakdown(id, {
        breakdown: {
          character_name: form.character_name,
          description: form.description,
          visibility: form.visibility,
          status: form.status,
          published_at: new Date().toISOString(),
        },
        criteria: {
          portrayal_age_min: Number(form.portrayal_age_min),
          portrayal_age_max: Number(form.portrayal_age_max),
          gender_presentation: 'any',
          union_requirement: form.union_requirement,
          local_hire_required: true,
          required_location: project?.location_summary || null,
          travel_provided: null,
          work_authorization: null,
        },
        skill_requirements: form.skill_id
          ? [{ skill_id: form.skill_id, requirement_level: form.requirement_level }]
          : [],
      })
      const refreshed = await api.getProject(id)
      setProject(refreshed.project)
      setForm((current) => ({ ...current, character_name: '', description: '' }))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not create breakdown')
    } finally {
      setCreating(false)
    }
  }

  if (!project && !error) return <p className="loading">Loading project…</p>
  if (!project) return <p className="error banner">{error}</p>

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <Link to={homePath} className="muted">
            ← Home
          </Link>
          <p className="brand">{project.name}</p>
          <p className="muted">
            {project.project_type.replaceAll('_', ' ')}
            {project.casting_office_name ? ` · ${project.casting_office_name}` : ''}
          </p>
        </div>
      </header>

      {error && <p className="error banner">{error}</p>}

      <main className="workspace single">
        <section>
          <div className="section-head">
            <h1>Breakdowns</h1>
            <p>{project.description}</p>
          </div>
          <div className="list">
            {(project.breakdowns || []).map((breakdown) => (
              <Link key={breakdown.id} to={`/breakdowns/${breakdown.id}`} className="list-item">
                <div>
                  <strong>{breakdown.character_name}</strong>
                  <span className="muted"> · {breakdown.status}</span>
                </div>
                <span className={`pill visibility-${breakdown.visibility}`}>
                  {breakdown.visibility.replaceAll('_', ' ')}
                </span>
              </Link>
            ))}
          </div>
        </section>

        {user?.personas.casting_professional && (
          <form className="panel stack" onSubmit={onCreateBreakdown}>
            <h2>Add breakdown</h2>
            <label>
              Character
              <input
                value={form.character_name}
                onChange={(e) => setForm({ ...form, character_name: e.target.value })}
                required
              />
            </label>
            <label>
              Description
              <textarea
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                rows={4}
                required
              />
            </label>
            <label>
              Visibility
              <select
                value={form.visibility}
                onChange={(e) => setForm({ ...form, visibility: e.target.value })}
              >
                <option value="public">Public</option>
                <option value="representatives_only">Representatives only</option>
                <option value="private">Private</option>
              </select>
            </label>
            <div className="row">
              <label>
                Age min
                <input
                  value={form.portrayal_age_min}
                  onChange={(e) => setForm({ ...form, portrayal_age_min: e.target.value })}
                />
              </label>
              <label>
                Age max
                <input
                  value={form.portrayal_age_max}
                  onChange={(e) => setForm({ ...form, portrayal_age_max: e.target.value })}
                />
              </label>
            </div>
            <label>
              Skill requirement
              <select
                value={form.skill_id}
                onChange={(e) => setForm({ ...form, skill_id: e.target.value })}
              >
                {skills.map((skill) => (
                  <option key={skill.id} value={skill.id}>
                    {skill.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Requirement level
              <select
                value={form.requirement_level}
                onChange={(e) => setForm({ ...form, requirement_level: e.target.value })}
              >
                <option value="required">Required</option>
                <option value="preferred">Preferred</option>
                <option value="nice_to_have">Nice to have</option>
              </select>
            </label>
            <button type="submit" disabled={creating}>
              {creating ? 'Publishing…' : 'Publish breakdown'}
            </button>
          </form>
        )}
      </main>
    </div>
  )
}
