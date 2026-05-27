class ScoreCalculator
  def initialize(challenge:, hints_penalty:, time_seconds:, quality_bonus: 0)
    @challenge = challenge
    @hints_penalty = hints_penalty
    @time_seconds = time_seconds
    @quality_bonus = quality_bonus
  end

  def calculate
    base = @challenge.base_score
    difficulty_bonus = (base * (@challenge.difficulty_multiplier - 1)).to_i
    time_bonus = time_bonus_for(@time_seconds)
    score = base + difficulty_bonus + time_bonus + @quality_bonus - @hints_penalty
  end

  def xp
    xp = @challenge.xp_reward
    xp += (xp * (@challenge.difficulty_multiplier - 1) * 0.5).to_i
    xp = [xp - (@hints_penalty / 10), 10].max
    xp
  end

  private

  def time_bonus_for(seconds)
    return 0 unless seconds

    case seconds
    when 0..60 then 200
    when 61..180 then 100
    when 181..300 then 50
    else 0
    end
  end
end
