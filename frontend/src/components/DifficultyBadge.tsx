import clsx from "clsx";

const colors: Record<string, string> = {
  easy: "bg-green-500/20 text-green-400 border-green-500/30",
  medium: "bg-yellow-500/20 text-yellow-400 border-yellow-500/30",
  hard: "bg-orange-500/20 text-orange-400 border-orange-500/30",
  expert: "bg-red-500/20 text-red-400 border-red-500/30"
};

export default function DifficultyBadge({ difficulty }: { difficulty: string }) {
  return (
    <span className={clsx("px-2.5 py-0.5 rounded-full text-xs font-medium border capitalize", colors[difficulty] || colors.medium)}>
      {difficulty}
    </span>
  );
}
