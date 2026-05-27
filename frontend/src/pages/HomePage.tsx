import { Link } from "react-router-dom";
import { Shield, Zap, Users, Wallet } from "lucide-react";
import { useAuthStore } from "../store/authStore";

export default function HomePage() {
  const { user } = useAuthStore();

  return (
    <div>
      <section className="text-center py-16 md:py-24">
        <h1 className="text-4xl md:text-6xl font-bold tracking-tight">
          Hunt Bugs.{" "}
          <span className="bg-gradient-to-r from-brand-400 to-cyan-300 bg-clip-text text-transparent">
            Earn Rewards.
          </span>
        </h1>
        <p className="mt-6 text-lg text-slate-400 max-w-2xl mx-auto">
          AI-generated vulnerable code challenges. Fix bugs, climb the leaderboard, mint NFT badges, and compete in real-time multiplayer rooms.
        </p>
        <div className="mt-10 flex flex-wrap justify-center gap-4">
          <Link to="/challenges" className="btn-primary text-lg px-8 py-3">Start Hunting</Link>
          {!user && <Link to="/register" className="btn-secondary text-lg px-8 py-3">Create Account</Link>}
        </div>
      </section>

      <section className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mt-8">
        {[
          { icon: Shield, title: "AI Challenges", desc: "Dynamically generated buggy code across 8 languages" },
          { icon: Zap, title: "Smart Evaluation", desc: "Sandbox execution + AI analysis of your fixes" },
          { icon: Users, title: "Multiplayer Rooms", desc: "Real-time competitive bug hunting with friends" },
          { icon: Wallet, title: "NFT Badges", desc: "Mint on-chain proof of your achievements" }
        ].map(({ icon: Icon, title, desc }) => (
          <div key={title} className="card text-center">
            <Icon className="h-10 w-10 text-brand-400 mx-auto mb-4" />
            <h3 className="font-semibold">{title}</h3>
            <p className="text-slate-400 text-sm mt-2">{desc}</p>
          </div>
        ))}
      </section>
    </div>
  );
}
