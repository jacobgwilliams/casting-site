import { useEffect, useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import {
  api,
  type ActorAttribute,
  type ActorProfile,
  type ActorSkill,
  type ProfileAttribute,
  type RepresentativeProfile,
} from '../api'
import { useAuth } from '../auth'

type Tab = 'account' | 'actor' | 'casting' | 'representative'

export function AccountPage() {
  const { user, logout, refresh } = useAuth()
  const [tab, setTab] = useState<Tab>('account')
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  const [accountForm, setAccountForm] = useState({
    first_name: '',
    last_name: '',
    phone_number: '',
    current_password: '',
    password: '',
    password_confirmation: '',
  })

  const [actorForm, setActorForm] = useState({
    professional_name: '',
    union_status: '',
    primary_location: '',
    timezone: '',
    profile_status: 'draft',
  })

  const [castingForm, setCastingForm] = useState({
    professional_title: '',
  })

  const [representativeProfile, setRepresentativeProfile] = useState<RepresentativeProfile | null>(
    null,
  )
  const [actorSkills, setActorSkills] = useState<ActorSkill[]>([])
  const [actorAttributes, setActorAttributes] = useState<ActorAttribute[]>([])
  const [skillCatalog, setSkillCatalog] = useState<Array<{ id: string; name: string }>>([])
  const [attributeCatalog, setAttributeCatalog] = useState<ProfileAttribute[]>([])
  const [skillForm, setSkillForm] = useState({
    skill_id: '',
    proficiency: '',
    years_experience: '',
  })
  const [attributeForm, setAttributeForm] = useState({
    profile_attribute_id: '',
    visibility: 'private',
  })

  useEffect(() => {
    if (!user) return

    setAccountForm({
      first_name: user.first_name,
      last_name: user.last_name,
      phone_number: user.phone_number ?? '',
      current_password: '',
      password: '',
      password_confirmation: '',
    })

    void loadProfiles()
  }, [user])

  async function loadProfiles() {
    if (!user) return

    setError(null)

    try {
      const requests: Promise<void>[] = []

      if (user.personas.actor) {
        requests.push(
          api.getActorProfile().then((data) => {
            setActorForm({
              professional_name: data.actor_profile.professional_name ?? '',
              union_status: data.actor_profile.union_status ?? '',
              primary_location: data.actor_profile.primary_location ?? '',
              timezone: data.actor_profile.timezone ?? '',
              profile_status: data.actor_profile.profile_status,
            })
          }),
        )
        requests.push(
          api.listActorSkills().then((data) => {
            setActorSkills(data.actor_skills)
          }),
        )
        requests.push(
          api.listActorAttributes().then((data) => {
            setActorAttributes(data.actor_attributes)
          }),
        )
        requests.push(
          api.listSkills().then((data) => {
            setSkillCatalog(data.skills.map((skill) => ({ id: skill.id, name: skill.name })))
          }),
        )
        requests.push(
          api.listProfileAttributes().then((data) => {
            setAttributeCatalog(data.profile_attributes)
          }),
        )
      }

      if (user.personas.casting_professional) {
        requests.push(
          api.getCastingProfessionalProfile().then((data) => {
            setCastingForm({
              professional_title: data.casting_professional_profile.professional_title ?? '',
            })
          }),
        )
      }

      if (user.personas.representative) {
        requests.push(
          api.getRepresentativeProfile().then((data) => {
            setRepresentativeProfile(data.representative_profile)
          }),
        )
      }

      await Promise.all(requests)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load profiles')
    }
  }

  async function onSaveAccount(event: FormEvent) {
    event.preventDefault()
    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      const payload: Parameters<typeof api.updateSession>[0] = {
        first_name: accountForm.first_name,
        last_name: accountForm.last_name,
        phone_number: accountForm.phone_number || null,
      }

      if (accountForm.password) {
        payload.current_password = accountForm.current_password
        payload.password = accountForm.password
        payload.password_confirmation = accountForm.password_confirmation
      }

      await api.updateSession(payload)
      await refresh()
      setAccountForm((current) => ({
        ...current,
        current_password: '',
        password: '',
        password_confirmation: '',
      }))
      setSuccess('Account updated.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not update account')
    } finally {
      setSaving(false)
    }
  }

  async function onSaveActor(event: FormEvent) {
    event.preventDefault()
    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      await api.updateActorProfile(actorForm as Partial<ActorProfile>)
      setSuccess('Actor profile updated.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not update actor profile')
    } finally {
      setSaving(false)
    }
  }

  async function onSaveCasting(event: FormEvent) {
    event.preventDefault()
    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      await api.updateCastingProfessionalProfile(castingForm)
      setSuccess('Casting profile updated.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not update casting profile')
    } finally {
      setSaving(false)
    }
  }

  async function onAddSkill(event: FormEvent) {
    event.preventDefault()
    if (!skillForm.skill_id) return

    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      await api.createActorSkill({
        skill_id: skillForm.skill_id,
        proficiency: skillForm.proficiency || undefined,
        years_experience: skillForm.years_experience
          ? Number(skillForm.years_experience)
          : null,
      })
      const data = await api.listActorSkills()
      setActorSkills(data.actor_skills)
      setSkillForm({ skill_id: '', proficiency: '', years_experience: '' })
      setSuccess('Skill added.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not add skill')
    } finally {
      setSaving(false)
    }
  }

  async function onRemoveSkill(skillId: string) {
    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      await api.deleteActorSkill(skillId)
      setActorSkills((current) => current.filter((skill) => skill.id !== skillId))
      setSuccess('Skill removed.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not remove skill')
    } finally {
      setSaving(false)
    }
  }

  async function onAddAttribute(event: FormEvent) {
    event.preventDefault()
    if (!attributeForm.profile_attribute_id) return

    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      await api.createActorAttribute({
        profile_attribute_id: attributeForm.profile_attribute_id,
        visibility: attributeForm.visibility,
      })
      const data = await api.listActorAttributes()
      setActorAttributes(data.actor_attributes)
      setAttributeForm({ profile_attribute_id: '', visibility: 'private' })
      setSuccess('Attribute added.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not add attribute')
    } finally {
      setSaving(false)
    }
  }

  async function onRemoveAttribute(attributeId: string) {
    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      await api.deleteActorAttribute(attributeId)
      setActorAttributes((current) => current.filter((attribute) => attribute.id !== attributeId))
      setSuccess('Attribute removed.')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not remove attribute')
    } finally {
      setSaving(false)
    }
  }

  const usedSkillIds = new Set(actorSkills.map((skill) => skill.skill_id))
  const availableSkills = skillCatalog.filter((skill) => !usedSkillIds.has(skill.id))
  const usedAttributeIds = new Set(actorAttributes.map((attribute) => attribute.profile_attribute_id))
  const availableAttributes = attributeCatalog.filter(
    (attribute) => !usedAttributeIds.has(attribute.id),
  )

  const tabs: Array<{ id: Tab; label: string; show: boolean }> = [
    { id: 'account', label: 'Account', show: true },
    { id: 'actor', label: 'Actor', show: !!user?.personas.actor },
    { id: 'casting', label: 'Casting', show: !!user?.personas.casting_professional },
    {
      id: 'representative',
      label: user?.personas.representative_type === 'manager' ? 'Manager' : 'Agent',
      show: !!user?.personas.representative,
    },
  ]

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <p className="brand">Casting Site</p>
          <p className="muted">My account</p>
        </div>
        <div className="topbar-actions">
          <Link to="/" className="ghost button-link">
            Dashboard
          </Link>
          <button type="button" className="ghost" onClick={() => void logout()}>
            Sign out
          </button>
        </div>
      </header>

      {error && <p className="error banner">{error}</p>}
      {success && <p className="success banner">{success}</p>}

      <main className="detail account-page">
        <nav className="tab-bar" aria-label="Profile sections">
          {tabs
            .filter((item) => item.show)
            .map((item) => (
              <button
                key={item.id}
                type="button"
                className={tab === item.id ? 'tab active' : 'tab'}
                onClick={() => {
                  setTab(item.id)
                  setSuccess(null)
                  setError(null)
                }}
              >
                {item.label}
              </button>
            ))}
        </nav>

        {tab === 'account' && (
          <form className="panel stack" onSubmit={onSaveAccount}>
            <div className="section-head">
              <h1>Account</h1>
              <p>Basic contact info and password.</p>
            </div>
            <label>
              Email
              <input value={user?.email ?? ''} disabled />
            </label>
            <div className="row">
              <label>
                First name
                <input
                  value={accountForm.first_name}
                  onChange={(e) => setAccountForm({ ...accountForm, first_name: e.target.value })}
                  required
                />
              </label>
              <label>
                Last name
                <input
                  value={accountForm.last_name}
                  onChange={(e) => setAccountForm({ ...accountForm, last_name: e.target.value })}
                  required
                />
              </label>
            </div>
            <label>
              Phone number
              <input
                value={accountForm.phone_number}
                onChange={(e) => setAccountForm({ ...accountForm, phone_number: e.target.value })}
              />
            </label>
            <div className="section-head">
              <h2>Change password</h2>
              <p>Leave blank to keep your current password.</p>
            </div>
            <label>
              Current password
              <input
                type="password"
                value={accountForm.current_password}
                onChange={(e) =>
                  setAccountForm({ ...accountForm, current_password: e.target.value })
                }
                autoComplete="current-password"
              />
            </label>
            <div className="row">
              <label>
                New password
                <input
                  type="password"
                  value={accountForm.password}
                  onChange={(e) => setAccountForm({ ...accountForm, password: e.target.value })}
                  autoComplete="new-password"
                />
              </label>
              <label>
                Confirm new password
                <input
                  type="password"
                  value={accountForm.password_confirmation}
                  onChange={(e) =>
                    setAccountForm({ ...accountForm, password_confirmation: e.target.value })
                  }
                  autoComplete="new-password"
                />
              </label>
            </div>
            <button type="submit" disabled={saving}>
              {saving ? 'Saving…' : 'Save account'}
            </button>
          </form>
        )}

        {tab === 'actor' && user?.personas.actor && (
          <>
            <form className="panel stack" onSubmit={onSaveActor}>
              <div className="section-head">
                <h1>Actor profile</h1>
                <p>How you appear to casting and representation.</p>
              </div>
              <label>
                Professional name
                <input
                  value={actorForm.professional_name}
                  onChange={(e) => setActorForm({ ...actorForm, professional_name: e.target.value })}
                />
              </label>
              <label>
                Union status
                <input
                  value={actorForm.union_status}
                  onChange={(e) => setActorForm({ ...actorForm, union_status: e.target.value })}
                  placeholder="e.g. SAG-AFTRA, Non-union"
                />
              </label>
              <label>
                Primary location
                <input
                  value={actorForm.primary_location}
                  onChange={(e) => setActorForm({ ...actorForm, primary_location: e.target.value })}
                  placeholder="e.g. Chicago, IL"
                />
              </label>
              <label>
                Timezone
                <input
                  value={actorForm.timezone}
                  onChange={(e) => setActorForm({ ...actorForm, timezone: e.target.value })}
                  placeholder="e.g. America/Chicago"
                />
              </label>
              <label>
                Profile status
                <select
                  value={actorForm.profile_status}
                  onChange={(e) => setActorForm({ ...actorForm, profile_status: e.target.value })}
                >
                  <option value="draft">Draft</option>
                  <option value="active">Active</option>
                  <option value="hidden">Hidden</option>
                </select>
              </label>
              <button type="submit" disabled={saving}>
                {saving ? 'Saving…' : 'Save actor profile'}
              </button>
            </form>

            <section className="panel stack">
              <div className="section-head">
                <h2>Skills</h2>
                <p>Add skills with proficiency from the catalog.</p>
              </div>
              <div className="list">
                {actorSkills.length === 0 && <p className="muted">No skills added yet.</p>}
                {actorSkills.map((skill) => (
                  <article key={skill.id} className="list-item">
                    <div>
                      <strong>{skill.skill_name}</strong>
                      {skill.proficiency && <span className="muted"> · {skill.proficiency}</span>}
                    </div>
                    <button type="button" className="ghost" onClick={() => void onRemoveSkill(skill.id)}>
                      Remove
                    </button>
                  </article>
                ))}
              </div>
              {availableSkills.length > 0 && (
                <form className="stack" onSubmit={onAddSkill}>
                  <label>
                    Skill
                    <select
                      value={skillForm.skill_id}
                      onChange={(e) => setSkillForm({ ...skillForm, skill_id: e.target.value })}
                      required
                    >
                      <option value="">Select skill…</option>
                      {availableSkills.map((skill) => (
                        <option key={skill.id} value={skill.id}>
                          {skill.name}
                        </option>
                      ))}
                    </select>
                  </label>
                  <label>
                    Proficiency
                    <input
                      value={skillForm.proficiency}
                      onChange={(e) => setSkillForm({ ...skillForm, proficiency: e.target.value })}
                      placeholder="e.g. conversational, expert"
                    />
                  </label>
                  <label>
                    Years experience
                    <input
                      type="number"
                      min="0"
                      value={skillForm.years_experience}
                      onChange={(e) =>
                        setSkillForm({ ...skillForm, years_experience: e.target.value })
                      }
                    />
                  </label>
                  <button type="submit" disabled={saving}>
                    Add skill
                  </button>
                </form>
              )}
            </section>

            <section className="panel stack">
              <div className="section-head">
                <h2>Attributes</h2>
                <p>Structured profile tags with visibility controls.</p>
              </div>
              <div className="list">
                {actorAttributes.length === 0 && <p className="muted">No attributes added yet.</p>}
                {actorAttributes.map((attribute) => (
                  <article key={attribute.id} className="list-item">
                    <div>
                      <strong>{attribute.profile_attribute_name}</strong>
                      <span className="muted"> · {attribute.visibility.replaceAll('_', ' ')}</span>
                    </div>
                    <button
                      type="button"
                      className="ghost"
                      onClick={() => void onRemoveAttribute(attribute.id)}
                    >
                      Remove
                    </button>
                  </article>
                ))}
              </div>
              {availableAttributes.length > 0 && (
                <form className="stack" onSubmit={onAddAttribute}>
                  <label>
                    Attribute
                    <select
                      value={attributeForm.profile_attribute_id}
                      onChange={(e) =>
                        setAttributeForm({
                          ...attributeForm,
                          profile_attribute_id: e.target.value,
                        })
                      }
                      required
                    >
                      <option value="">Select attribute…</option>
                      {availableAttributes.map((attribute) => (
                        <option key={attribute.id} value={attribute.id}>
                          {attribute.name}
                        </option>
                      ))}
                    </select>
                  </label>
                  <label>
                    Visibility
                    <select
                      value={attributeForm.visibility}
                      onChange={(e) =>
                        setAttributeForm({ ...attributeForm, visibility: e.target.value })
                      }
                    >
                      <option value="public">Public</option>
                      <option value="representatives">Representatives</option>
                      <option value="casting_only">Casting only</option>
                      <option value="private">Private</option>
                    </select>
                  </label>
                  <button type="submit" disabled={saving}>
                    Add attribute
                  </button>
                </form>
              )}
            </section>
          </>
        )}

        {tab === 'casting' && user?.personas.casting_professional && (
          <form className="panel stack" onSubmit={onSaveCasting}>
            <div className="section-head">
              <h1>Casting profile</h1>
              <p>Your professional identity in casting offices.</p>
            </div>
            <label>
              Professional title
              <input
                value={castingForm.professional_title}
                onChange={(e) => setCastingForm({ ...castingForm, professional_title: e.target.value })}
                placeholder="e.g. Casting Director"
              />
            </label>
            <button type="submit" disabled={saving}>
              {saving ? 'Saving…' : 'Save casting profile'}
            </button>
          </form>
        )}

        {tab === 'representative' && user?.personas.representative && representativeProfile && (
          <section className="panel stack">
            <div className="section-head">
              <h1>{representativeProfile.representative_type === 'manager' ? 'Manager' : 'Agent'} profile</h1>
              <p>Representative type is set at registration and cannot be changed here.</p>
            </div>
            <dl className="meta">
              <div>
                <dt>Type</dt>
                <dd>{representativeProfile.representative_type}</dd>
              </div>
            </dl>
          </section>
        )}
      </main>
    </div>
  )
}
