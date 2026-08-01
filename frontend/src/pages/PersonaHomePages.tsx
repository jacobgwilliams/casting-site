import { Link } from 'react-router-dom'
import { useAuth } from '../auth'
import { PersonaNav } from '../components/PersonaNav'

export function PersonaLandingPage() {
  const { user, logout } = useAuth()
  const personas = user
    ? ([
        user.personas.casting_professional && {
          title: 'Casting',
          description: 'Manage projects, breakdowns, and casting offices.',
          path: '/casting',
        },
        user.personas.actor && {
          title: 'Actor',
          description: 'Edit your profile, representation, and skills.',
          path: '/actor',
        },
        user.personas.representative && {
          title: user.personas.representative_type === 'manager' ? 'Manager' : 'Agent',
          description: 'Manage offices, divisions, and your roster.',
          path: '/rep',
        },
      ].filter(Boolean) as Array<{ title: string; description: string; path: string }>)
    : []

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">Choose a workspace</p>
        </div>
        <div className="topbar-actions">
          <Link to="/account" className="ghost button-link">
            My account
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      <main className="workspace">
        <section>
          <div className="section-head">
            <h1>Welcome back{user ? `, ${user.first_name}` : ''}</h1>
            <p>You have multiple personas. Pick where you want to work.</p>
          </div>
          <div className="list">
            {personas.map((persona) => (
              <Link key={persona.path} to={persona.path} className="list-item">
                <div>
                  <strong>{persona.title}</strong>
                  <p className="muted">{persona.description}</p>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </main>
    </div>
  )
}

export function CastingHomePage() {
  const { user, logout } = useAuth()

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">Casting workspace</p>
        </div>
        <div className="topbar-actions">
          <PersonaNav current="casting" />
          <Link to="/offices" className="ghost button-link">
            Offices
          </Link>
          <Link to="/account" className="ghost button-link">
            My account
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      <main className="workspace">
        <section className="panel stack">
          <div className="section-head">
            <h1>Casting home</h1>
            <p>Signed in as {user?.full_name}</p>
          </div>
          <div className="list">
            <Link to="/casting/breakdowns" className="list-item">
              <strong>Visible breakdowns</strong>
              <span className="muted">Browse published roles</span>
            </Link>
            <Link to="/casting/projects" className="list-item">
              <strong>Projects</strong>
              <span className="muted">Create and manage casting projects</span>
            </Link>
            <Link to="/offices" className="list-item">
              <strong>Offices</strong>
              <span className="muted">Casting offices you belong to</span>
            </Link>
          </div>
        </section>
      </main>
    </div>
  )
}

export function ActorHomePage() {
  const { user, logout } = useAuth()

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">Actor workspace</p>
        </div>
        <div className="topbar-actions">
          <PersonaNav current="actor" />
          <Link to="/account" className="ghost button-link">
            My account
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      <main className="workspace">
        <section className="panel stack">
          <div className="section-head">
            <h1>Actor home</h1>
            <p>Signed in as {user?.full_name}</p>
          </div>
          <div className="list">
            <Link to="/account" className="list-item">
              <strong>Profile & skills</strong>
              <span className="muted">Edit your actor profile, skills, and attributes</span>
            </Link>
            <Link to="/actor/representation" className="list-item">
              <strong>My representation</strong>
              <span className="muted">Agencies and management companies</span>
            </Link>
            <Link to="/actor/breakdowns" className="list-item">
              <strong>Visible breakdowns</strong>
              <span className="muted">Roles you can see</span>
            </Link>
          </div>
        </section>
      </main>
    </div>
  )
}

export function RepHomePage() {
  const { user, logout } = useAuth()

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">
            {user?.personas.representative_type === 'manager' ? 'Manager' : 'Agent'} workspace
          </p>
        </div>
        <div className="topbar-actions">
          <PersonaNav current="rep" />
          <Link to="/offices" className="ghost button-link">
            Offices
          </Link>
          <Link to="/account" className="ghost button-link">
            My account
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      <main className="workspace">
        <section className="panel stack">
          <div className="section-head">
            <h1>{user?.personas.representative_type === 'manager' ? 'Manager' : 'Agent'} home</h1>
            <p>Signed in as {user?.full_name}</p>
          </div>
          <div className="list">
            <Link to="/rep/roster" className="list-item">
              <strong>My roster</strong>
              <span className="muted">Represented actors and division coverage</span>
            </Link>
            <Link to="/offices" className="list-item">
              <strong>Offices</strong>
              <span className="muted">Agencies and management companies</span>
            </Link>
            <Link to="/rep/breakdowns" className="list-item">
              <strong>Visible breakdowns</strong>
              <span className="muted">Representative-only and public roles</span>
            </Link>
          </div>
        </section>
      </main>
    </div>
  )
}
