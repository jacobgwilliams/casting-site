import { Link } from 'react-router-dom'
import { useAuth } from '../auth'
import { personaLinks } from '../personas'

export function PersonaNav({ current }: { current?: string }) {
  const { user } = useAuth()
  if (!user) return null

  const links = personaLinks(user)
  if (links.length <= 1) return null

  return (
    <nav className="persona-nav" aria-label="Personas">
      {links.map((link) => (
        <Link
          key={link.key}
          to={link.path}
          className={current === link.key ? 'ghost button-link active' : 'ghost button-link'}
        >
          {link.label}
        </Link>
      ))}
    </nav>
  )
}
