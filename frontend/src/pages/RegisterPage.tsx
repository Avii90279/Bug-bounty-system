import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import api from "../lib/api";
import { useAuthStore } from "../store/authStore";

export default function RegisterPage() {
  const [form, setForm] = useState({ email: "", username: "", password: "", password_confirmation: "" });
  const [loading, setLoading] = useState(false);
  const { setAuth } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.password !== form.password_confirmation) {
      toast.error("Passwords do not match");
      return;
    }
    setLoading(true);
    try {
      const { data } = await api.post("/auth/register", { user: form });
      setAuth(data.user, data.access_token, data.refresh_token);
      toast.success("Account created!");
      navigate("/challenges");
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { errors?: string[] } } })?.response?.data?.errors?.[0];
      toast.error(msg || "Registration failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto card mt-12">
      <h1 className="text-2xl font-bold mb-6">Create Account</h1>
      <form onSubmit={handleSubmit} className="space-y-4">
        {(["email", "username", "password", "password_confirmation"] as const).map((field) => (
          <input
            key={field}
            type={field.includes("password") ? "password" : field === "email" ? "email" : "text"}
            placeholder={field.replace("_", " ").replace(/\b\w/g, (c) => c.toUpperCase())}
            className="input"
            value={form[field]}
            onChange={(e) => setForm({ ...form, [field]: e.target.value })}
            required
          />
        ))}
        <button type="submit" className="btn-primary w-full" disabled={loading}>
          {loading ? "Creating..." : "Sign Up"}
        </button>
      </form>
      <p className="mt-6 text-center text-slate-400 text-sm">
        Have an account? <Link to="/login" className="text-brand-400 hover:underline">Login</Link>
      </p>
    </div>
  );
}
