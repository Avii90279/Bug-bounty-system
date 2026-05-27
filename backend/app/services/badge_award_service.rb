class BadgeAwardService
  def initialize(user)
    @user = user
  end

  def check_all!
    Badge.find_each { |badge| award_if_eligible!(badge) }
  end

  def check_after_submission!(submission)
    check_all!
    check_fast_solve!(submission)
    check_no_hints!(submission)
  end

  private

  def award_if_eligible!(badge)
    return if @user.badges.exists?(badge.id)

    eligible = case badge.criteria_type
               when "solves_count"
                 @user.submissions.passed.select(:challenge_id).distinct.count >= badge.criteria_value
               when "xp_total"
                 @user.xp >= badge.criteria_value
               when "expert_solves"
                 @user.submissions.passed.joins(:challenge).where(challenges: { difficulty: :expert }).count >= badge.criteria_value
               when "languages_solved"
                 @user.submissions.passed.joins(:challenge).select("DISTINCT challenges.language").count >= badge.criteria_value
               else
                 false
               end

    award!(badge) if eligible
  end

  def check_fast_solve!(submission)
    badge = Badge.find_by(criteria_type: :fast_solve)
    return unless badge && submission.time_taken_seconds.to_i <= badge.criteria_value

    award!(badge) unless @user.badges.exists?(badge.id)
  end

  def check_no_hints!(submission)
    return if submission.hints_used.positive?

    badge = Badge.find_by(criteria_type: :no_hints_streak)
    return unless badge

    streak = @user.submissions.passed.where(hints_used: 0).limit(badge.criteria_value).count
    award!(badge) if streak >= badge.criteria_value
  end

  def award!(badge)
    @user.user_badges.create!(badge: badge, earned_at: Time.current)
  end
end
