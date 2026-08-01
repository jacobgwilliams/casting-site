import { useState, type FormEvent } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth'
import { defaultPersonaPath } from '../personas'

export function LoginPage() {
  const { user, login } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('casting@example.com')
  const [password, setPassword] = useState('password123')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  if (user) return <Navigate to="/" replace />

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    setSubmitting(true)
    setError(null)
    try {
      const signedInUser = await login(email, password)
      navigate(defaultPersonaPath(signedInUser))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="auth-shell">
      <section className="auth-panel">
        <p className="brand">Casting Site</p>
        <h1>Sign in</h1>
        <p className="lede">Use a seeded account to explore the casting vertical slice.</p>
        <form onSubmit={onSubmit} className="stack">
          <label>
            Email
            <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required />
          </label>
          <label>
            Password
            <input
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              type="password"
              required
            />
          </label>
          {error && <p className="error">{error}</p>}
          <button type="submit" disabled={submitting}>
            {submitting ? 'Signing in…' : 'Sign in'}
          </button>
        </form>
        <p className="muted">
          No account? <Link to="/register">Register</Link>
        </p>
        <ul className="seed-list">
          <li>casting@example.com</li>
          <li>actor@example.com</li>
          <li>agent@example.com</li>
        </ul>
      </section>
    </main>
  )
}
