class GenerateChallengeJob
  include Sidekiq::Job

  def perform(user_id, difficulty, language, topic = nil)
    user = User.find(user_id)
    result = AiChallengeGenerator.new(difficulty: difficulty, language: language, topic: topic).generate!

    Challenge.create!(
      title: result[:title],
      description: result[:description],
      buggy_code: result[:buggy_code],
      solution_code: result[:solution_code],
      test_cases: result[:test_cases] || [],
      difficulty: difficulty,
      language: language,
      ai_generated: true,
      created_by: user
    )
  end
end
