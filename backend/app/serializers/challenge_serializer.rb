class ChallengeSerializer
  def initialize(challenge, include_code: false, user: nil)
    @challenge = challenge
    @include_code = include_code
    @user = user
  end

  def as_json
    data = {
      id: @challenge.id,
      title: @challenge.title,
      description: @challenge.description,
      difficulty: @challenge.difficulty,
      language: @challenge.language,
      monaco_language: @challenge.monaco_language,
      xp_reward: @challenge.xp_reward,
      base_score: @challenge.base_score,
      ai_generated: @challenge.ai_generated,
      attempts_count: @challenge.attempts_count,
      solves_count: @challenge.solves_count,
      hints_count: @challenge.hints.count,
      created_at: @challenge.created_at
    }

    if @include_code
      data[:buggy_code] = @challenge.buggy_code
      data[:hints_used] = @user ? @user.hint_usages.where(challenge: @challenge).pluck(:hint_id) : []
    end

    data
  end
end
