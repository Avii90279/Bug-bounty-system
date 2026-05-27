import { Outlet, Link, useNavigate } from "react-router-dom";
import { Bug, Moon, Sun, Menu, X } from "lucide-react";
import { useState } from "react";
import { useAuthStore } from "../store/authStore";
import { useThemeStore } from "../store/themeStore";
import clsx from "clsx";

const navLinks = [
  { to: "/challenges", label: "Challenges" },
  { to: "/leaderboard", label: "Leaderboard" },
  { to: "/badges", label: "Badges" },
  { to: "/rooms", label: "Rooms", auth: true }
];

export default function Layout() {
  const { user, logout } = useAuthStore();
  const { darkMode, toggle } = useThemeStore();
  const navigate = useNavigate();
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <div className="min-h-screen bg-gradient-to-br from-surface-950 via-surface-900 to-brand-900/20">
      <header className="sticky top-0 z-50 border-b border-slate-800/80 bg-surface-950/80 backdrop-blur-lg">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4">
          <Link to="/" className="flex items-center gap-2 font-bold text-xl">
            <Bug className="h-7 w-7 text-brand-400" />
            <span className="bg-gradient-to-r from-brand-400 to-teal-300 bg-clip-text text-transparent">
              BugBounty
            </span>
          </Link>

          <nav className="hidden md:flex items-center gap-6">
            {navLinks.map((link) => {
              if (link.auth && !user) return null;
              return (
                <Link key={link.to} to={link.to} className="text-slate-300 hover:text-brand-400 transition-colors">
                  {link.label}
                </Link>
              );
            })}
            {user?.role === "admin" && (
              <Link to="/admin" className="text-amber-400 hover:text-amber-300">Admin</Link>
            )}
          </nav>

          <div className="flex items-center gap-3">
            <button onClick={toggle} className="p-2 rounded-lg hover:bg-slate-800" aria-label="Toggle theme">
              {darkMode ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
            </button>
            {user ? (
              <button onClick={() => navigate("/profile")} className="hidden sm:flex items-center gap-2 btn-secondary text-sm">
                <span className="text-brand-400 font-mono">{user.xp} XP</span>
                <span>{user.username}</span>
              </button>
            ) : (
              <div className="hidden sm:flex gap-2">
                <Link to="/login" className="btn-secondary text-sm">Login</Link>
                <Link to="/register" className="btn-primary text-sm">Sign Up</Link>
              </div>
            )}
            <button className="md:hidden p-2" onClick={() => setMobileOpen(!mobileOpen)}>
              {mobileOpen ? <X /> : <Menu />}
            </button>
          </div>
        </div>

        <div className={clsx("md:hidden border-t border-slate-800", mobileOpen ? "block" : "hidden")}>
          <div className="flex flex-col gap-2 p-4">
            {navLinks.map((link) => (
              <Link key={link.to} to={link.to} onClick={() => setMobileOpen(false)} className="py-2">{link.label}</Link>
            ))}
            {user ? (
              <>
                <Link to="/profile" onClick={() => setMobileOpen(false)}>Profile</Link>
                <button onClick={() => { logout(); setMobileOpen(false); }} className="text-left text-red-400 py-2">Logout</button>
              </>
            ) : (
              <Link to="/login" className="btn-primary text-center" onClick={() => setMobileOpen(false)}>Login</Link>
            )}
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-7xl px-4 py-8">
        <Outlet />
      </main>

      <footer className="border-t border-slate-800 py-8 text-center text-slate-500 text-sm">
        BugBounty Platform — AI-Powered Security Challenges
      </footer>
    </div>
  );
}
