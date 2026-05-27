export interface User {
  id: number;
  email?: string;
  username: string;
  avatar_url?: string;
  xp: number;
  score: number;
  role: string;
  badges?: BadgeEarned[];
}

export interface BadgeEarned {
  slug: string;
  name: string;
  icon: string;
  earned_at: string;
}

export interface Challenge {
  id: number;
  title: string;
  description: string;
  difficulty: string;
  language: string;
  monaco_language: string;
  xp_reward: number;
  base_score: number;
  ai_generated: boolean;
  attempts_count: number;
  solves_count: number;
  hints_count: number;
  buggy_code?: string;
  hints_used?: number[];
  created_at: string;
}

export interface Submission {
  id: number;
  challenge_id: number;
  challenge_title?: string;
  status: string;
  score_awarded: number;
  xp_awarded: number;
  ai_feedback?: string;
  evaluation_result?: Record<string, unknown>;
  hints_used: number;
  time_taken_seconds?: number;
  created_at: string;
}

export interface Badge {
  id: number;
  name: string;
  slug: string;
  description: string;
  icon: string;
  nft_eligible: boolean;
  earned?: boolean;
}

export interface Room {
  id: number;
  code: string;
  name: string;
  status: string;
  host_id: number;
  challenge_id?: number;
  participants: RoomParticipant[];
}

export interface RoomParticipant {
  user_id: number;
  username: string;
  score: number;
  finished: boolean;
}

export interface LeaderboardEntry {
  rank: number;
  username: string;
  score: number;
  xp: number;
  badges_count: number;
}

export interface NftBadge {
  id: number;
  badge: Badge;
  token_id?: string;
  tx_hash?: string;
  status: string;
  minted_at?: string;
}
