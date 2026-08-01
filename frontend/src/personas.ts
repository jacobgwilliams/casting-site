import type { User } from './api'

export type PersonaKey = 'casting' | 'actor' | 'rep'

export type PersonaLink = {
  key: PersonaKey
  label: string
  path: string
}

export function personaLinks(user: User): PersonaLink[] {
  const links: PersonaLink[] = []

  if (user.personas.casting_professional) {
    links.push({ key: 'casting', label: 'Casting', path: '/casting' })
  }
  if (user.personas.actor) {
    links.push({ key: 'actor', label: 'Actor', path: '/actor' })
  }
  if (user.personas.representative) {
    links.push({
      key: 'rep',
      label: user.personas.representative_type === 'manager' ? 'Manager' : 'Agent',
      path: '/rep',
    })
  }

  return links
}

export function defaultPersonaPath(user: User): string {
  const links = personaLinks(user)
  if (links.length === 1) return links[0].path
  return '/'
}

export function hasMultiplePersonas(user: User): boolean {
  return personaLinks(user).length > 1
}
