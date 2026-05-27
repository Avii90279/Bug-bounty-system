import { useEffect, useState } from "react";
import toast from "react-hot-toast";
import api from "../lib/api";
import { useAuthStore } from "../store/authStore";
import { connectWallet, mintNftBadge } from "../lib/wallet";
import type { Badge } from "../types";

export default function BadgesPage() {
  const [badges, setBadges] = useState<Badge[]>([]);
  const { user } = useAuthStore();

  useEffect(() => {
    if (user) api.get("/badges").then(({ data }) => setBadges(data.badges));
  }, [user]);

  const handleMint = async (badgeId: number) => {
    try {
      await connectWallet(user!.id);
      await mintNftBadge(badgeId);
      toast.success("NFT badge minted!");
    } catch (err: unknown) {
      toast.error((err as Error).message || "Mint failed");
    }
  };

  if (!user) return <p className="text-center text-slate-400 py-20">Login to view badges</p>;

  return (
    <div>
      <h1 className="text-3xl font-bold mb-8">Badges & NFTs</h1>
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {badges.map((b) => (
          <div key={b.id} className={`card ${b.earned ? "border-brand-500/50" : "opacity-60"}`}>
            <div className="text-4xl mb-3">{b.icon}</div>
            <h3 className="font-semibold">{b.name}</h3>
            <p className="text-slate-400 text-sm mt-1">{b.description}</p>
            {b.earned ? (
              <span className="inline-block mt-3 text-xs text-brand-400 bg-brand-500/10 px-2 py-1 rounded">Earned</span>
            ) : (
              <span className="inline-block mt-3 text-xs text-slate-500">Locked</span>
            )}
            {b.earned && b.nft_eligible && (
              <button onClick={() => handleMint(b.id)} className="btn-secondary w-full mt-4 text-sm">
                Mint NFT
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
