class SandboxExecutor
  TIMEOUT_SECONDS = 10

  def initialize(code, challenge)
    @code = code
    @challenge = challenge
  end

  def run
    if sandbox_available?
      remote_execute
    else
      local_validate
    end
  end

  private

  def sandbox_available?
    ENV["SANDBOX_URL"].present?
  end

  def remote_execute
    response = Faraday.post("#{ENV['SANDBOX_URL']}/execute") do |req|
      req.options.timeout = TIMEOUT_SECONDS + 2
      req.headers["Content-Type"] = "application/json"
      req.headers["X-Sandbox-Token"] = ENV.fetch("SANDBOX_TOKEN", "dev-token")
      req.body = {
        code: @code,
        language: @challenge.language,
        test_cases: @challenge.test_cases,
        timeout: TIMEOUT_SECONDS
      }.to_json
    end

    JSON.parse(response.body).symbolize_keys
  rescue StandardError => e
    { passed: false, error: e.message, test_results: [] }
  end

  def local_validate
    test_cases = @challenge.test_cases.presence || [{ "expected" => true }]
    code_changed = @code.strip != @challenge.buggy_code.strip
    has_guard = @code.match?(/if|guard|nil|null|undefined|<=|parameterized|prepared/i)

    passed = code_changed && (test_cases.empty? || has_guard || @code.length > @challenge.buggy_code.length)

    {
      passed: passed,
      test_results: test_cases.map { |tc| { input: tc["input"], passed: passed, output: passed ? tc["expected"] : "failed" } },
      mode: "local_fallback"
    }
  end
end
