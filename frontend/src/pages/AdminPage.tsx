import { useEffect, useState } from "react";
import { BarChart3, Users, Bug, FileCode } from "lucide-react";
import api from "../lib/api";

interface DashboardStats {
  users: number;
  challenges: number;
  submissions: number;
  passed_submissions: number;
  active_rooms: number;
  ai_generated_challenges: number;
}

export default function AdminPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [analytics, setAnalytics] = useState<Record<string, unknown> | null>(null);

  useEffect(() => {
    api.get("/admin/dashboard").then(({ data }) => setStats(data.stats));
    api.get("/admin/analytics").then(({ data }) => setAnalytics(data));
  }, []);

  const statCards = stats
    ? [
        { icon: Users, label: "Users", value: stats.users },
        { icon: Bug, label: "Challenges", value: stats.challenges },
        { icon: FileCode, label: "Submissions", value: stats.submissions },
        { icon: BarChart3, label: "Pass Rate", value: `${stats.submissions ? Math.round((stats.passed_submissions / stats.submissions) * 100) : 0}%` }
      ]
    : [];

  return (
    <div>
      <h1 className="text-3xl font-bold mb-8">Admin Dashboard</h1>

      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {statCards.map(({ icon: Icon, label, value }) => (
          <div key={label} className="card">
            <Icon className="h-6 w-6 text-brand-400 mb-2" />
            <p className="text-2xl font-bold">{value}</p>
            <p className="text-slate-400 text-sm">{label}</p>
          </div>
        ))}
      </div>

      {analytics && (
        <div className="grid md:grid-cols-2 gap-6">
          <div className="card">
            <h2 className="font-semibold mb-4">By Difficulty</h2>
            <pre className="text-sm text-slate-400">{JSON.stringify(analytics.by_difficulty, null, 2)}</pre>
          </div>
          <div className="card">
            <h2 className="font-semibold mb-4">By Language</h2>
            <pre className="text-sm text-slate-400">{JSON.stringify(analytics.by_language, null, 2)}</pre>
          </div>
          <div className="card md:col-span-2">
            <h2 className="font-semibold mb-4">Submissions (30 days)</h2>
            <pre className="text-sm text-slate-400 overflow-auto">{JSON.stringify(analytics.daily_submissions, null, 2)}</pre>
          </div>
        </div>
      )}

      {stats && (
        <p className="text-slate-500 text-sm mt-6">
          {stats.ai_generated_challenges} AI-generated challenges · {stats.active_rooms} active rooms
        </p>
      )}
    </div>
  );
}
