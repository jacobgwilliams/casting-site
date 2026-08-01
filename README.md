# Casting Site

Rails 8 API + PostgreSQL backend and React (Vite) frontend for a casting platform.

Built from `casting_platform_database_schema.txt` MVP boundary and first vertical slice:

> A casting director belonging to a casting office creates a project, adds a breakdown with structured requirements, marks it public or representatives-only, and the appropriate users can view it.

## Stack

- **Backend:** Rails 8 API, PostgreSQL, Pundit, cookie sessions
- **Frontend:** React + TypeScript (Vite), proxied to the API in development

## Setup

```bash
# Backend
bundle install
bin/rails db:setup   # create, migrate, seed

# Frontend
cd frontend && npm install
```

## Run

In two terminals:

```bash
bin/rails server        # http://localhost:3000
cd frontend && npm run dev   # http://localhost:5173
```

Open http://localhost:5173 and sign in with seeded users:

| Email | Password | Persona |
|---|---|---|
| casting@example.com | password123 | Casting professional |
| actor@example.com | password123 | Actor |
| agent@example.com | password123 | Agent |

Actors see public breakdowns. Agents also see `representatives_only` breakdowns.

## API (v1)

| Method | Path | Notes |
|---|---|---|
| POST | `/api/v1/session` | Login |
| GET | `/api/v1/session` | Current user |
| PATCH | `/api/v1/session` | Update account (name, phone, password) |
| DELETE | `/api/v1/session` | Logout |
| POST | `/api/v1/registrations` | Register + personas |
| GET/PATCH | `/api/v1/actor_profile` | Actor profile |
| GET/PATCH | `/api/v1/casting_professional_profile` | Casting profile |
| GET/PATCH | `/api/v1/representative_profile` | Representative profile (type read-only) |
| CRUD-ish | `/api/v1/organizations` | Index/show/create/update |
| CRUD-ish | `/api/v1/projects` | Index/show/create/update |
| POST | `/api/v1/projects/:id/breakdowns` | Create breakdown + criteria/skills |
| GET | `/api/v1/breakdowns` | Visibility-filtered list |
| GET | `/api/v1/breakdowns/:id` | Show if authorized |
| GET | `/api/v1/skills` | Skill catalog |

## Schema notes

- UUID primary keys throughout
- `citext` emails
- Personas are separate profile tables (not role flags on `users`)
- Organizations use `organization_type` (avoids Rails STI)
- Schema doc table `attributes` is implemented as `profile_attributes` to avoid clashing with ActiveRecord’s `attributes` API

## Deferred (per schema MVP)

Submissions, messaging, media, payments, OpenSearch, AI matching, audition scheduling.
