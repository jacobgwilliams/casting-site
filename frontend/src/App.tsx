import { Navigate, Route, Routes } from 'react-router-dom'
import { useAuth } from './auth'
import { BreakdownPage } from './pages/BreakdownPage'
import { DashboardPage } from './pages/DashboardPage'
import { AccountPage } from './pages/AccountPage'
import { OfficePage } from './pages/OfficePage'
import { OfficesPage } from './pages/OfficesPage'
import { LoginPage } from './pages/LoginPage'
import { ProjectPage } from './pages/ProjectPage'
import { RegisterPage } from './pages/RegisterPage'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth()
  if (loading) return <p className="loading">Loading…</p>
  if (!user) return <Navigate to="/login" replace />
  return children
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
            <DashboardPage />
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
