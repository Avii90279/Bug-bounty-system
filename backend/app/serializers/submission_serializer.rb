class SubmissionSerializer
  def initialize(submission)
    @submission = submission
  end

  def as_json
    {
      id: @submission.id,
      challenge_id: @submission.challenge_id,
      challenge_title: @submission.challenge&.title,
      status: @submission.status,
      score_awarded: @submission.score_awarded,
      xp_awarded: @submission.xp_awarded,
      ai_feedback: @submission.ai_feedback,
      evaluation_result: @submission.evaluation_result,
      hints_used: @submission.hints_used,
      time_taken_seconds: @submission.time_taken_seconds,
      created_at: @submission.created_at
    }
  end
end
