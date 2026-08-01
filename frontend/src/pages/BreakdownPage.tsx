import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { api, type Breakdown } from '../api'

export function BreakdownPage() {
  const { id } = useParams<{ id: string }>()
  const [breakdown, setBreakdown] = useState<Breakdown | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!id) return
    void (async () => {
      try {
        const data = await api.getBreakdown(id)
        setBreakdown(data.breakdown)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unable to load breakdown')
      }
    })()
  }, [id])

  if (error) {
    return (
      <div className="app-shell">
        <p className="error banner">{error}</p>
        <Link to="/">Back to dashboard</Link>
      </div>
    )
  }

  if (!breakdown) return <p className="loading">Loading breakdown…</p>

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <Link to={`/projects/${breakdown.project_id}`} className="muted">
            ← {breakdown.project_name}
          </Link>
          <p className="brand">{breakdown.character_name}</p>
          <p className="muted">
            {breakdown.visibility.replaceAll('_', ' ')} · {breakdown.status}
          </p>
        </div>
      </header>

      <main className="detail">
        <section>
          <h1>Role</h1>
          <p>{breakdown.description}</p>
        </section>

        {breakdown.criteria && (
          <section>
            <h2>Criteria</h2>
            <dl className="meta">
              <div>
                <dt>Portrayal age</dt>
                <dd>
                  {breakdown.criteria.portrayal_age_min ?? '—'}–
                  {breakdown.criteria.portrayal_age_max ?? '—'}
                </dd>
              </div>
              <div>
                <dt>Union</dt>
                <dd>{breakdown.criteria.union_requirement || '—'}</dd>
              </div>
              <div>
                <dt>Location</dt>
                <dd>{breakdown.criteria.required_location || '—'}</dd>
              </div>
              <div>
                <dt>Local hire</dt>
                <dd>{breakdown.criteria.local_hire_required ? 'Required' : 'Not required'}</dd>
              </div>
            </dl>
          </section>
        )}

        <section>
          <h2>Skills</h2>
          {breakdown.skill_requirements.length === 0 ? (
            <p className="muted">No skill requirements listed.</p>
          ) : (
            <ul className="plain-list">
              {breakdown.skill_requirements.map((req) => (
                <li key={req.id}>
                  <strong>{req.skill_name}</strong>
                  <span className="muted">
                    {' '}
                    · {req.requirement_level.replaceAll('_', ' ')}
                    {req.minimum_proficiency ? ` · ${req.minimum_proficiency}` : ''}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>
    </div>
  )
}
