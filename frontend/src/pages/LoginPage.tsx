import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { GoogleLogin } from "@react-oauth/google";
import toast from "react-hot-toast";
import api from "../lib/api";
import { useAuthStore } from "../store/authStore";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { setAuth } = useAuthStore();
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { data } = await api.post("/auth/login", { email, password });
      setAuth(data.user, data.access_token, data.refresh_token);
      toast.success("Welcome back!");
      navigate("/challenges");
    } catch {
      toast.error("Invalid credentials");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogle = async (credential: string) => {
    try {
      const { data } = await api.post("/auth/google", { id_token: credential });
      setAuth(data.user, data.access_token, data.refresh_token);
      toast.success("Signed in with Google");
      navigate("/challenges");
    } catch {
      toast.error("Google sign-in failed");
    }
  };

  return (
    <div className="max-w-md mx-auto card mt-12">
      <h1 className="text-2xl font-bold mb-6">Login</h1>
      <form onSubmit={handleLogin} className="space-y-4">
        <input type="email" placeholder="Email" className="input" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <input type="password" placeholder="Password" className="input" value={password} onChange={(e) => setPassword(e.target.value)} required />
        <button type="submit" className="btn-primary w-full" disabled={loading}>
          {loading ? "Signing in..." : "Login"}
        </button>
      </form>
      <div className="my-6 flex items-center gap-4">
        <div className="flex-1 h-px bg-slate-700" />
        <span className="text-slate-500 text-sm">or</span>
        <div className="flex-1 h-px bg-slate-700" />
      </div>
      <div className="flex justify-center">
        <GoogleLogin
          onSuccess={(res) => res.credential && handleGoogle(res.credential)}
          onError={() => toast.error("Google login failed")}
          theme="filled_black"
          size="large"
          width="100%"
        />
      </div>
      <p className="mt-6 text-center text-slate-400 text-sm">
        No account? <Link to="/register" className="text-brand-400 hover:underline">Sign up</Link>
      </p>
    </div>
  );
}
