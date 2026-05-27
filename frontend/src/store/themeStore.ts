import { create } from "zustand";
import { persist } from "zustand/middleware";

interface ThemeState {
  darkMode: boolean;
  toggle: () => void;
  initTheme: () => void;
}

export const useThemeStore = create<ThemeState>()(
  persist(
    (set, get) => ({
      darkMode: true,
      toggle: () => set({ darkMode: !get().darkMode }),
      initTheme: () => {
        const stored = get().darkMode;
        document.documentElement.classList.toggle("dark", stored);
      }
    }),
    { name: "bugbounty-theme" }
  )
);
