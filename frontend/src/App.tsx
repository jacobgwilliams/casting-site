import { Navigate, Route, Routes } from 'react-router-dom'
import { useAuth } from './auth'
import { defaultPersonaPath, hasMultiplePersonas } from './personas'
import { BreakdownPage } from './pages/BreakdownPage'
import { AccountPage } from './pages/AccountPage'
import { OfficePage } from './pages/OfficePage'
import { OfficesPage } from './pages/OfficesPage'
import { LoginPage } from './pages/LoginPage'
import { ProjectPage } from './pages/ProjectPage'
import { RegisterPage } from './pages/RegisterPage'
import { RepresentationPage } from './pages/RepresentationPage'
import { RosterPage } from './pages/RosterPage'
import {
  ActorHomePage,
  CastingHomePage,
  PersonaLandingPage,
  RepHomePage,
} from './pages/PersonaHomePages'
import { WorkspaceBreakdownsPage, WorkspaceProjectsPage } from './pages/WorkspacePages'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth()
  if (loading) return <p className="loading">Loading…</p>
  if (!user) return <Navigate to="/login" replace />
  return children
}

function PersonaRoot() {
  const { user, loading } = useAuth()
  if (loading) return <p className="loading">Loading…</p>
  if (!user) return <Navigate to="/login" replace />
  if (hasMultiplePersonas(user)) return <PersonaLandingPage />
  return <Navigate to={defaultPersonaPath(user)} replace />
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <PersonaRoot />
          </ProtectedRoute>
        }
      />
      <Route
        path="/casting"
        element={
          <ProtectedRoute>
            <CastingHomePage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/casting/breakdowns"
        element={
          <ProtectedRoute>
            <WorkspaceBreakdownsPage persona="casting" title="Casting breakdowns" />
          </ProtectedRoute>
        }
      />
      <Route
        path="/casting/projects"
        element={
          <ProtectedRoute>
            <WorkspaceProjectsPage
              persona="casting"
              title="Casting projects"
              showProjectCreate
            />
          </ProtectedRoute>
        }
      />
      <Route
        path="/actor"
        element={
          <ProtectedRoute>
            <ActorHomePage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/actor/representation"
        element={
          <ProtectedRoute>
            <RepresentationPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/actor/breakdowns"
        element={
          <ProtectedRoute>
            <WorkspaceBreakdownsPage persona="actor" title="Actor breakdowns" />
          </ProtectedRoute>
        }
      />
      <Route
        path="/rep"
        element={
          <ProtectedRoute>
            <RepHomePage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/rep/roster"
        element={
          <ProtectedRoute>
            <RosterPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/rep/breakdowns"
        element={
          <ProtectedRoute>
            <WorkspaceBreakdownsPage persona="rep" title="Rep breakdowns" />
          </ProtectedRoute>
        }
      />
      <Route
        path="/offices"
        element={
          <ProtectedRoute>
            <OfficesPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/offices/:id"
        element={
          <ProtectedRoute>
            <OfficePage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/account"
        element={
          <ProtectedRoute>
            <AccountPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/projects/:id"
        element={
          <ProtectedRoute>
            <ProjectPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/breakdowns/:id"
        element={
          <ProtectedRoute>
            <BreakdownPage />
          </ProtectedRoute>
        }
      />
    </Routes>
  )
}
