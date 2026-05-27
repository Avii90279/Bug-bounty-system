import { useEffect, useState } from "react";
import { Trophy } from "lucide-react";
import api from "../lib/api";
import type { LeaderboardEntry } from "../types";

export default function LeaderboardPage() {
  const [entries, setEntries] = useState<LeaderboardEntry[]>([]);

  useEffect(() => {
    api.get("/leaderboard").then(({ data }) => setEntries(data.leaderboard));
  }, []);

  const medals = ["🥇", "🥈", "🥉"];

  return (
    <div>
      <h1 className="text-3xl font-bold flex items-center gap-3 mb-8">
        <Trophy className="h-8 w-8 text-amber-400" /> Leaderboard
      </h1>
      <div className="card overflow-hidden p-0">
        <table className="w-full">
          <thead>
            <tr className="border-b border-slate-800 text-left text-slate-400 text-sm">
              <th className="p-4">Rank</th>
              <th className="p-4">Hacker</th>
              <th className="p-4">Score</th>
              <th className="p-4">XP</th>
              <th className="p-4 hidden sm:table-cell">Badges</th>
            </tr>
          </thead>
          <tbody>
            {entries.map((e) => (
              <tr key={e.rank} className="border-b border-slate-800/50 hover:bg-slate-800/30">
                <td className="p-4 font-mono">
                  {e.rank <= 3 ? medals[e.rank - 1] : `#${e.rank}`}
                </td>
                <td className="p-4 font-medium">{e.username}</td>
                <td className="p-4 text-brand-400 font-mono">{e.score.toLocaleString()}</td>
                <td className="p-4 font-mono">{e.xp.toLocaleString()}</td>
                <td className="p-4 hidden sm:table-cell text-slate-400">{e.badges_count}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
