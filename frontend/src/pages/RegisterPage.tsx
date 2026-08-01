import { useState, type FormEvent } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { api } from '../api'
import { useAuth } from '../auth'

const PERSONA_OPTIONS = [
  { id: 'actor', label: 'Actor' },
  { id: 'casting_professional', label: 'Casting professional' },
  { id: 'agent', label: 'Agent' },
  { id: 'manager', label: 'Manager' },
]

export function RegisterPage() {
  const { user, refresh } = useAuth()
  const navigate = useNavigate()
  const [form, setForm] = useState({
    first_name: '',
    last_name: '',
    email: '',
    password: '',
    password_confirmation: '',
  })
  const [personas, setPersonas] = useState<string[]>(['casting_professional'])
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  if (user) return <Navigate to="/" replace />

  function togglePersona(id: string) {
    setPersonas((current) =>
      current.includes(id) ? current.filter((p) => p !== id) : [...current, id],
    )
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    setSubmitting(true)
    setError(null)
    try {
      await api.register({ user: form, personas })
      await refresh()
      navigate('/')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Registration failed')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="auth-shell">
      <section className="auth-panel">
        <p className="brand">Casting Site</p>
        <h1>Create account</h1>
        <p className="lede">Pick one or more personas. Roles live on profiles, not the user.</p>
        <form onSubmit={onSubmit} className="stack">
          <div className="row">
            <label>
              First name
              <input
                value={form.first_name}
                onChange={(e) => setForm({ ...form, first_name: e.target.value })}
                required
              />
            </label>
            <label>
              Last name
              <input
                value={form.last_name}
                onChange={(e) => setForm({ ...form, last_name: e.target.value })}
                required
              />
            </label>
          </div>
          <label>
            Email
            <input
              type="email"
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              required
            />
          </label>
          <label>
            Password
            <input
              type="password"
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
              required
            />
          </label>
          <label>
            Confirm password
            <input
              type="password"
              value={form.password_confirmation}
              onChange={(e) => setForm({ ...form, password_confirmation: e.target.value })}
              required
            />
          </label>
          <fieldset className="persona-set">
            <legend>Personas</legend>
            {PERSONA_OPTIONS.map((option) => (
              <label key={option.id} className="check">
                <input
                  type="checkbox"
                  checked={personas.includes(option.id)}
                  onChange={() => togglePersona(option.id)}
                />
                {option.label}
              </label>
            ))}
          </fieldset>
          {error && <p className="error">{error}</p>}
          <button type="submit" disabled={submitting || personas.length === 0}>
            {submitting ? 'Creating…' : 'Create account'}
          </button>
        </form>
        <p className="muted">
          Already registered? <Link to="/login">Sign in</Link>
        </p>
      </section>
    </main>
  )
}
