import { create } from "zustand";
import { persist } from "zustand/middleware";
import api from "../lib/api";
import type { User } from "../types";

interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  loading: boolean;
  setAuth: (user: User, accessToken: string, refreshToken: string) => void;
  logout: () => void;
  fetchMe: () => Promise<void>;
  updateUser: (user: User) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      refreshToken: null,
      loading: false,
      setAuth: (user, token, refreshToken) => set({ user, token, refreshToken }),
      logout: () => set({ user: null, token: null, refreshToken: null }),
      fetchMe: async () => {
        if (!get().token) return;
        set({ loading: true });
        try {
          const { data } = await api.get("/auth/me");
          set({ user: data.user, loading: false });
        } catch {
          set({ user: null, token: null, refreshToken: null, loading: false });
        }
      },
      updateUser: (user) => set({ user })
    }),
    { name: "bugbounty-auth", partialize: (s) => ({ token: s.token, refreshToken: s.refreshToken }) }
  )
);
