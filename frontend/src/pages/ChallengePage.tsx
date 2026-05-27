import { useEffect, useState, useRef } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Lightbulb, Send, Clock } from "lucide-react";
import toast from "react-hot-toast";
import api from "../lib/api";
import { getCableConsumer } from "../lib/cable";
import { useAuthStore } from "../store/authStore";
import type { Challenge, Submission } from "../types";
import CodeEditor from "../components/CodeEditor";
import DifficultyBadge from "../components/DifficultyBadge";

export default function ChallengePage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user, token } = useAuthStore();
  const [challenge, setChallenge] = useState<Challenge | null>(null);
  const [code, setCode] = useState("");
  const [hints, setHints] = useState<{ level: number; content: string; score_penalty: number }[]>([]);
  const [totalPenalty, setTotalPenalty] = useState(0);
  const [submitting, setSubmitting] = useState(false);
  const [submission, setSubmission] = useState<Submission | null>(null);
  const startTime = useRef(Date.now());

  useEffect(() => {
    api.get(`/challenges/${id}`).then(({ data }) => {
      setChallenge(data);
      setCode(data.buggy_code || "");
    });
  }, [id]);

  useEffect(() => {
    if (!token || !user) return;
    const consumer = getCableConsumer();
    const sub = consumer.subscriptions.create("SubmissionChannel", {
      received(data: { submission: Submission }) {
        if (data.submission.challenge_id === Number(id)) {
          setSubmission(data.submission);
          setSubmitting(false);
          if (data.submission.status === "passed") {
            toast.success(`Solved! +${data.submission.score_awarded} pts, +${data.submission.xp_awarded} XP`);
          } else if (data.submission.status === "failed") {
            toast.error("Fix not accepted — try again");
          }
        }
      }
    });
    return () => sub.unsubscribe();
  }, [token, user, id]);

  const requestHint = async (level: number) => {
    if (!user) {
      toast.error("Login to use hints");
      return;
    }
    try {
      const { data } = await api.post(`/challenges/${id}/hint`, { level });
      setHints((prev) => [...prev.filter((h) => h.level !== level), data.hint]);
      setTotalPenalty(data.total_penalty);
      toast(`Hint revealed (-${data.hint.score_penalty} pts)`, { icon: "💡" });
    } catch {
      toast.error("Could not load hint");
    }
  };

  const handleSubmit = async () => {
    if (!user) {
      navigate("/login");
      return;
    }
    setSubmitting(true);
    setSubmission(null);
    const timeTaken = Math.floor((Date.now() - startTime.current) / 1000);
    try {
      const { data } = await api.post(`/challenges/${id}/submit`, { code, time_taken_seconds: timeTaken });
      setSubmission(data.submission);
      toast.success("Evaluating your fix...");
    } catch {
      toast.error("Submit failed");
      setSubmitting(false);
    }
  };

  if (!challenge) return <div className="text-center py-20">Loading...</div>;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl font-bold">{challenge.title}</h1>
            <DifficultyBadge difficulty={challenge.difficulty} />
          </div>
          <p className="text-slate-400 mt-2">{challenge.description}</p>
          <div className="flex gap-4 mt-2 text-sm text-slate-500">
            <span>{challenge.language}</span>
            <span>{challenge.base_score} base pts</span>
            <span>{challenge.xp_reward} XP</span>
            {totalPenalty > 0 && <span className="text-amber-400">-{totalPenalty} hint penalty</span>}
          </div>
        </div>
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-4">
          <CodeEditor value={code} onChange={setCode} language={challenge.monaco_language} height="450px" />
          <div className="flex flex-wrap gap-3">
            <button onClick={handleSubmit} disabled={submitting} className="btn-primary flex items-center gap-2">
              <Send className="h-4 w-4" />
              {submitting ? "Evaluating..." : "Submit Fix"}
            </button>
            {[1, 2, 3].map((level) => (
              <button key={level} onClick={() => requestHint(level)} className="btn-secondary flex items-center gap-2 text-sm">
                <Lightbulb className="h-4 w-4" /> Hint {level}
              </button>
            ))}
          </div>
        </div>

        <div className="space-y-4">
          {hints.map((h) => (
            <div key={h.level} className="card border-amber-500/30">
              <p className="text-xs text-amber-400 font-medium">Hint {h.level} (-{h.score_penalty} pts)</p>
              <p className="mt-2 text-sm">{h.content}</p>
            </div>
          ))}

          {submission && (
            <div className={`card ${submission.status === "passed" ? "border-green-500/50" : "border-red-500/50"}`}>
              <p className="font-medium capitalize">{submission.status}</p>
              {submission.ai_feedback && <p className="text-sm text-slate-400 mt-2">{submission.ai_feedback}</p>}
              {submission.status === "passed" && (
                <p className="text-brand-400 mt-2">+{submission.score_awarded} pts · +{submission.xp_awarded} XP</p>
              )}
            </div>
          )}

          <div className="card text-sm text-slate-400">
            <p className="flex items-center gap-2"><Clock className="h-4 w-4" /> Faster solves earn bonus points</p>
            <p className="mt-2">{challenge.solves_count} hackers solved this</p>
          </div>
        </div>
      </div>
    </div>
  );
}
