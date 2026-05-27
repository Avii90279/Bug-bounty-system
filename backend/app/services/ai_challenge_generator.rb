class AiChallengeGenerator
  DIFFICULTY_PROMPTS = {
    "easy" => "introductory bug (off-by-one, missing null check)",
    "medium" => "logic flaw or input validation issue",
    "hard" => "concurrency, race condition, or memory safety",
    "expert" => "subtle security vulnerability (injection, auth bypass)"
  }.freeze

  def initialize(difficulty:, language:, topic: nil)
    @difficulty = difficulty
    @language = language
    @topic = topic || "general software bug"
  end

  def generate!
    response = call_ai_api
    parse_response(response)
  end

  private

  def call_ai_api
    api_key = ENV["OPENAI_API_KEY"]
    return mock_response if api_key.blank?

    Faraday.post("https://api.openai.com/v1/chat/completions") do |req|
      req.headers["Authorization"] = "Bearer #{api_key}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        response_format: { type: "json_object" },
        temperature: 0.8
      }.to_json
    end.then { |r| JSON.parse(r.body) }
  rescue StandardError => e
    Rails.logger.warn("AI generation failed: #{e.message}")
    mock_response
  end

  def system_prompt
    <<~PROMPT
      You are a bug bounty challenge creator. Return JSON with keys:
      title, description, buggy_code, solution_code, test_cases (array of {input, expected}),
      hints (array of {level, content, score_penalty}).
      The buggy_code must contain a realistic intentional bug for #{@difficulty} difficulty.
    PROMPT
  end

  def user_prompt
    "Create a #{@difficulty} #{@language} challenge about #{@topic}. Bug type: #{DIFFICULTY_PROMPTS[@difficulty]}."
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    data = content.is_a?(String) ? JSON.parse(content) : response
    data.deep_symbolize_keys
  end

  def mock_response
    {
      "choices" => [{
        "message" => {
          "content" => {
            title: "#{@difficulty.capitalize} #{@language.capitalize} Null Dereference",
            description: "Fix the null pointer access before the method returns.",
            buggy_code: mock_buggy_code,
            solution_code: "Add null guard before access",
            test_cases: [{ input: { value: nil }, expected: 0 }],
            hints: [
              { level: 1, content: "Check what happens when input is nil.", score_penalty: 75 },
              { level: 2, content: "Add an early return for null/undefined.", score_penalty: 125 }
            ]
          }.to_json
        }
      }]
    }
  end

  def mock_buggy_code
    case @language
    when "python"
      "def process(data):\n    return data['value'] * 2"
    when "ruby"
      "def process(data)\n  data[:value] * 2\nend"
    when "javascript", "typescript"
      "function process(data) {\n  return data.value * 2;\n}"
    else
      "// Fix the bug in this #{@language} code\nfunction process(data) { return data.value; }"
    end
  end
end
