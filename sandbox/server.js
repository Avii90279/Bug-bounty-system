const express = require("express");
const { execFile } = require("child_process");
const fs = require("fs");
const path = require("path");
const { v4: uuidv4 } = require("uuid");

const app = express();
app.use(express.json({ limit: "100kb" }));

const SANDBOX_TOKEN = process.env.SANDBOX_TOKEN || "dev-token";
const WORK_DIR = process.env.WORK_DIR || "/tmp/sandbox";
const MAX_TIMEOUT = 10;

const RUNNERS = {
  javascript: { ext: ".js", cmd: "node" },
  typescript: { ext: ".ts", cmd: "node" },
  python: { ext: ".py", cmd: "python3" },
  ruby: { ext: ".rb", cmd: "ruby" },
  go: { ext: ".go", cmd: "go", run: "run" },
  java: { ext: ".java", cmd: "java" },
  cpp: { ext: ".cpp", cmd: "g++" },
  rust: { ext: ".rs", cmd: "rustc" }
};

function auth(req, res, next) {
  if (req.headers["x-sandbox-token"] !== SANDBOX_TOKEN) {
    return res.status(401).json({ error: "Unauthorized" });
  }
  next();
}

app.get("/health", (_, res) => res.json({ status: "ok" }));

app.post("/execute", auth, async (req, res) => {
  const { code, language, test_cases = [], timeout = MAX_TIMEOUT } = req.body;
  if (!code || !language) {
    return res.status(400).json({ error: "code and language required" });
  }

  const runner = RUNNERS[language];
  if (!runner) {
    return res.status(400).json({ error: `Unsupported language: ${language}` });
  }

  const jobId = uuidv4();
  const jobDir = path.join(WORK_DIR, jobId);

  try {
    fs.mkdirSync(jobDir, { recursive: true });
    const filePath = path.join(jobDir, `main${runner.ext}`);
    const wrapped = wrapCode(code, language, test_cases);
    fs.writeFileSync(filePath, wrapped, { mode: 0o400 });

    const result = await runInSandbox(filePath, runner, Math.min(timeout, MAX_TIMEOUT));
    const testResults = evaluateTests(result.stdout, test_cases, result.exitCode === 0);

    res.json({
      passed: testResults.every((t) => t.passed) && result.exitCode === 0,
      stdout: result.stdout.slice(0, 2000),
      stderr: result.stderr.slice(0, 2000),
      test_results: testResults,
      execution_time_ms: result.duration
    });
  } catch (err) {
    res.status(500).json({ passed: false, error: err.message, test_results: [] });
  } finally {
    fs.rmSync(jobDir, { recursive: true, force: true });
  }
});

function wrapCode(code, language, testCases) {
  if (language === "javascript" || language === "typescript") {
    return `${code}\nconsole.log("__SANDBOX_OK__");`;
  }
  if (language === "python") {
    return `${code}\nprint("__SANDBOX_OK__")`;
  }
  if (language === "ruby") {
    return `${code}\nputs "__SANDBOX_OK__"`;
  }
  return code;
}

function runInSandbox(filePath, runner, timeoutSec) {
  return new Promise((resolve) => {
    const start = Date.now();
    const args = runner.run ? [runner.run, filePath] : [filePath];
    const cmd = runner.cmd;

    const child = execFile(
      cmd,
      args,
      {
        timeout: timeoutSec * 1000,
        maxBuffer: 512 * 1024,
        cwd: path.dirname(filePath),
        env: { PATH: process.env.PATH, HOME: "/tmp", NODE_ENV: "production" },
        uid: 1000,
        gid: 1000
      },
      (error, stdout, stderr) => {
        resolve({
          stdout: stdout || "",
          stderr: stderr || (error ? error.message : ""),
          exitCode: error ? (error.code || 1) : 0,
          duration: Date.now() - start
        });
      }
    );
    child.on("error", (err) => {
      resolve({ stdout: "", stderr: err.message, exitCode: 1, duration: Date.now() - start });
    });
  });
}

function evaluateTests(stdout, testCases, executed) {
  if (!testCases.length) {
    return [{ passed: executed && stdout.includes("__SANDBOX_OK__"), output: stdout.trim() }];
  }
  return testCases.map((tc) => ({
    input: tc.input,
    expected: tc.expected,
    passed: executed,
    output: stdout.trim().slice(0, 500)
  }));
}

fs.mkdirSync(WORK_DIR, { recursive: true });
app.listen(8080, "0.0.0.0", () => console.log("Sandbox listening on :8080"));
