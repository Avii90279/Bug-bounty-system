import { Link } from "react-router-dom";
import { Code2, Trophy, Users } from "lucide-react";
import type { Challenge } from "../types";
import DifficultyBadge from "./DifficultyBadge";

export default function ChallengeCard({ challenge }: { challenge: Challenge }) {
  return (
    <Link to={`/challenges/${challenge.id}`} className="card hover:border-brand-500/50 transition-all group block">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h3 className="font-semibold text-lg group-hover:text-brand-400 transition-colors">{challenge.title}</h3>
          <p className="text-slate-400 text-sm mt-1 line-clamp-2">{challenge.description}</p>
        </div>
        <DifficultyBadge difficulty={challenge.difficulty} />
      </div>
      <div className="flex flex-wrap gap-4 mt-4 text-sm text-slate-400">
        <span className="flex items-center gap-1"><Code2 className="h-4 w-4" />{challenge.language}</span>
        <span className="flex items-center gap-1"><Trophy className="h-4 w-4" />{challenge.base_score} pts</span>
        <span className="flex items-center gap-1"><Users className="h-4 w-4" />{challenge.solves_count} solves</span>
        {challenge.ai_generated && (
          <span className="text-brand-400 text-xs bg-brand-500/10 px-2 py-0.5 rounded">AI Generated</span>
        )}
      </div>
    </Link>
  );
}
