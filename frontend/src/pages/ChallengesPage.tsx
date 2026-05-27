import { useEffect, useState } from "react";
import { Sparkles } from "lucide-react";
import toast from "react-hot-toast";
import api from "../lib/api";
import { useAuthStore } from "../store/authStore";
import type { Challenge } from "../types";
import ChallengeCard from "../components/ChallengeCard";

const DIFFICULTIES = ["", "easy", "medium", "hard", "expert"];
const LANGUAGES = ["", "javascript", "python", "ruby", "java", "cpp", "go", "rust", "typescript"];

export default function ChallengesPage() {
  const [challenges, setChallenges] = useState<Challenge[]>([]);
  const [difficulty, setDifficulty] = useState("");
  const [language, setLanguage] = useState("");
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const { user } = useAuthStore();

  const fetchChallenges = async () => {
    setLoading(true);
    try {
      const params: Record<string, string> = {};
      if (difficulty) params.difficulty = difficulty;
      if (language) params.language = language;
      const { data } = await api.get("/challenges", { params });
      setChallenges(data.challenges);
    } catch {
      toast.error("Failed to load challenges");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchChallenges();
  }, [difficulty, language]);

  const generateChallenge = async () => {
    if (!user) {
      toast.error("Login to generate AI challenges");
      return;
    }
    setGenerating(true);
    try {
      const { data } = await api.post("/challenges/generate", {
        difficulty: difficulty || "medium",
        language: language || "javascript"
      });
      toast.success(`Generated: ${data.title}`);
      fetchChallenges();
    } catch {
      toast.error("Generation failed");
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div>
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-bold">Challenges</h1>
          <p className="text-slate-400 mt-1">Find and fix intentional bugs</p>
        </div>
        {user && (
          <button onClick={generateChallenge} disabled={generating} className="btn-primary flex items-center gap-2">
            <Sparkles className="h-4 w-4" />
            {generating ? "Generating..." : "AI Generate"}
          </button>
        )}
      </div>

      <div className="flex flex-wrap gap-3 mb-6">
        <select className="input w-auto" value={difficulty} onChange={(e) => setDifficulty(e.target.value)}>
          <option value="">All Difficulties</option>
          {DIFFICULTIES.filter(Boolean).map((d) => (
            <option key={d} value={d}>{d.charAt(0).toUpperCase() + d.slice(1)}</option>
          ))}
        </select>
        <select className="input w-auto" value={language} onChange={(e) => setLanguage(e.target.value)}>
          <option value="">All Languages</option>
          {LANGUAGES.filter(Boolean).map((l) => (
            <option key={l} value={l}>{l}</option>
          ))}
        </select>
      </div>

      {loading ? (
        <div className="text-center py-20 text-slate-400">Loading challenges...</div>
      ) : (
        <div className="grid md:grid-cols-2 gap-4">
          {challenges.map((c) => <ChallengeCard key={c.id} challenge={c} />)}
          {!challenges.length && <p className="text-slate-400 col-span-2 text-center py-12">No challenges found</p>}
        </div>
      )}
    </div>
  );
}
