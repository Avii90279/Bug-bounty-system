import Editor from "@monaco-editor/react";
import { useThemeStore } from "../store/themeStore";

interface CodeEditorProps {
  value: string;
  onChange: (value: string) => void;
  language: string;
  readOnly?: boolean;
  height?: string;
}

export default function CodeEditor({ value, onChange, language, readOnly, height = "400px" }: CodeEditorProps) {
  const { darkMode } = useThemeStore();

  return (
    <div className="rounded-lg overflow-hidden border border-slate-700">
      <Editor
        height={height}
        language={language}
        value={value}
        onChange={(v) => onChange(v || "")}
        theme={darkMode ? "vs-dark" : "light"}
        options={{
          minimap: { enabled: false },
          fontSize: 14,
          fontFamily: "JetBrains Mono, monospace",
          readOnly,
          scrollBeyondLastLine: false,
          padding: { top: 12 },
          automaticLayout: true
        }}
      />
    </div>
  );
}
