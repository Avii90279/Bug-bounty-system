module Api
  module V1
    module Admin
      class DashboardController < ApplicationController
        before_action :require_admin!

        def index
          render json: {
            stats: {
              users: User.count,
              challenges: Challenge.count,
              submissions: Submission.count,
              passed_submissions: Submission.passed.count,
              active_rooms: Room.active.count,
              ai_generated_challenges: Challenge.where(ai_generated: true).count
            },
            recent_submissions: Submission.order(created_at: :desc).limit(10).map { |s| SubmissionSerializer.new(s).as_json },
            top_challenges: Challenge.order(solves_count: :desc).limit(5).map { |c| ChallengeSerializer.new(c).as_json }
          }
        end
      end
    end
  end
end
