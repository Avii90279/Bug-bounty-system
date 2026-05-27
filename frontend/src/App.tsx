import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { Toaster } from "react-hot-toast";
import { useAuthStore } from "./store/authStore";
import { useThemeStore } from "./store/themeStore";
import { useEffect } from "react";
import Layout from "./components/Layout";
import HomePage from "./pages/HomePage";
import LoginPage from "./pages/LoginPage";
import RegisterPage from "./pages/RegisterPage";
import ChallengesPage from "./pages/ChallengesPage";
import ChallengePage from "./pages/ChallengePage";
import LeaderboardPage from "./pages/LeaderboardPage";
import ProfilePage from "./pages/ProfilePage";
import RoomsPage from "./pages/RoomsPage";
import RoomPage from "./pages/RoomPage";
import AdminPage from "./pages/AdminPage";
import BadgesPage from "./pages/BadgesPage";

function PrivateRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuthStore();
  if (loading) return <div className="flex h-screen items-center justify-center">Loading...</div>;
  return user ? <>{children}</> : <Navigate to="/login" />;
}

function AdminRoute({ children }: { children: React.ReactNode }) {
  const { user } = useAuthStore();
  if (!user || user.role !== "admin") return <Navigate to="/" />;
  return <>{children}</>;
}

export default function App() {
  const { darkMode, initTheme } = useThemeStore();
  const { fetchMe, token } = useAuthStore();

  useEffect(() => {
    initTheme();
  }, [initTheme]);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", darkMode);
  }, [darkMode]);

  useEffect(() => {
    if (token) fetchMe();
  }, [token, fetchMe]);

  return (
    <BrowserRouter>
      <Toaster position="top-right" toastOptions={{ className: "bg-surface-900 text-slate-100" }} />
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<HomePage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/challenges" element={<ChallengesPage />} />
          <Route path="/challenges/:id" element={<ChallengePage />} />
          <Route path="/leaderboard" element={<LeaderboardPage />} />
          <Route path="/badges" element={<BadgesPage />} />
          <Route path="/rooms" element={<PrivateRoute><RoomsPage /></PrivateRoute>} />
          <Route path="/rooms/:id" element={<PrivateRoute><RoomPage /></PrivateRoute>} />
          <Route path="/profile" element={<PrivateRoute><ProfilePage /></PrivateRoute>} />
          <Route path="/admin" element={<AdminRoute><AdminPage /></AdminRoute>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
