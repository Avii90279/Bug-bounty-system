import { useEffect, useState } from "react";
import { Wallet } from "lucide-react";
import toast from "react-hot-toast";
import api from "../lib/api";
import { useAuthStore } from "../store/authStore";
import { connectWallet } from "../lib/wallet";
import type { Submission } from "../types";

export default function ProfilePage() {
  const { user, fetchMe } = useAuthStore();
  const [submissions, setSubmissions] = useState<Submission[]>([]);
  const [wallet, setWallet] = useState<string | null>(null);

  useEffect(() => {
    api.get("/submissions").then(({ data }) => setSubmissions(data.submissions));
    api.get("/blockchain/wallet").then(({ data }) => setWallet(data.wallet?.address || null));
  }, []);

  const handleConnectWallet = async () => {
    try {
      const address = await connectWallet(user!.id);
      setWallet(address);
      toast.success("Wallet connected");
      fetchMe();
    } catch (err: unknown) {
      toast.error((err as Error).message);
    }
  };

  if (!user) return null;

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div className="card">
        <h1 className="text-2xl font-bold">{user.username}</h1>
        <p className="text-slate-400">{user.email}</p>
        <div className="flex gap-6 mt-4">
          <div><span className="text-3xl font-bold text-brand-400">{user.score}</span><p className="text-sm text-slate-500">Score</p></div>
          <div><span className="text-3xl font-bold">{user.xp}</span><p className="text-sm text-slate-500">XP</p></div>
          <div><span className="text-3xl font-bold">{user.badges?.length || 0}</span><p className="text-sm text-slate-500">Badges</p></div>
        </div>
        <button onClick={handleConnectWallet} className="btn-secondary mt-6 flex items-center gap-2">
          <Wallet className="h-4 w-4" />
          {wallet ? `Connected: ${wallet.slice(0, 6)}...${wallet.slice(-4)}` : "Connect Wallet"}
        </button>
      </div>

      {user.badges && user.badges.length > 0 && (
        <div className="card">
          <h2 className="font-semibold mb-4">Earned Badges</h2>
          <div className="flex flex-wrap gap-3">
            {user.badges.map((b) => (
              <span key={b.slug} className="bg-slate-800 px-3 py-2 rounded-lg text-sm">
                {b.icon} {b.name}
              </span>
            ))}
          </div>
        </div>
      )}

      <div className="card">
        <h2 className="font-semibold mb-4">Recent Submissions</h2>
        <div className="space-y-2">
          {submissions.slice(0, 10).map((s) => (
            <div key={s.id} className="flex justify-between text-sm border-b border-slate-800 pb-2">
              <span>{s.challenge_title}</span>
              <span className={s.status === "passed" ? "text-green-400" : "text-slate-500"}>{s.status}</span>
            </div>
          ))}
          {!submissions.length && <p className="text-slate-500">No submissions yet</p>}
        </div>
      </div>
    </div>
  );
}
