class AiEvaluator
  def initialize(challenge:, submission_code:)
    @challenge = challenge
    @code = submission_code
  end

  def evaluate
    sandbox_result = SandboxExecutor.new(@code, @challenge).run
    ai_analysis = analyze_with_ai(sandbox_result)

    {
      passed: sandbox_result[:passed] && ai_analysis[:fixes_bug],
      sandbox: sandbox_result,
      ai_feedback: ai_analysis[:feedback],
      score_modifier: ai_analysis[:quality_bonus],
      test_results: sandbox_result[:test_results]
    }
  end

  private

  def analyze_with_ai(sandbox_result)
    return mock_analysis(sandbox_result) if ENV["OPENAI_API_KEY"].blank?

    prompt = <<~PROMPT
      Challenge: #{@challenge.title}
      Buggy code: #{@challenge.buggy_code}
      User fix: #{@code}
      Sandbox result: #{sandbox_result.to_json}
      Does the fix address the root bug? Rate quality 0-100. Return JSON: {fixes_bug, feedback, quality_bonus}
    PROMPT

    response = Faraday.post("https://api.openai.com/v1/chat/completions") do |req|
      req.headers["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
        messages: [{ role: "user", content: prompt }],
        response_format: { type: "json_object" }
      }.to_json
    end

    JSON.parse(JSON.parse(response.body).dig("choices", 0, "message", "content")).symbolize_keys
  rescue StandardError
    mock_analysis(sandbox_result)
  end

  def mock_analysis(sandbox_result)
    passed = sandbox_result[:passed]
    {
      fixes_bug: passed,
      feedback: passed ? "Fix looks correct! Tests passed." : "Tests failed. Review edge cases and the root cause.",
      quality_bonus: passed ? 10 : 0
    }
  end
end
