class EvaluateSubmissionJob
  include Sidekiq::Job
  sidekiq_options queue: :critical, retry: 3

  def perform(submission_id)
    submission = Submission.find(submission_id)
    challenge = submission.challenge
    user = submission.user

    hints_penalty = user.hint_usages.where(challenge: challenge).joins(:hint).sum("hints.score_penalty")
    result = AiEvaluator.new(challenge: challenge, submission_code: submission.code).evaluate

    calculator = ScoreCalculator.new(
      challenge: challenge,
      hints_penalty: hints_penalty,
      time_seconds: submission.time_taken_seconds,
      quality_bonus: result[:score_modifier] || 0
    )

    if result[:passed]
      score = calculator.calculate
      xp = calculator.xp
      submission.update!(
        status: :passed,
        score_awarded: score,
        xp_awarded: xp,
        ai_feedback: result[:ai_feedback],
        evaluation_result: result
      )
      user.award_score!(score)
      user.award_xp!(xp)
      challenge.record_solve!(submission.time_taken_seconds || 0)
      BadgeAwardService.new(user).check_after_submission!(submission)
    else
      submission.update!(
        status: :failed,
        ai_feedback: result[:ai_feedback],
        evaluation_result: result
      )
    end

    SubmissionChannel.broadcast_to(user, submission: SubmissionSerializer.new(submission.reload).as_json)
  end
end
