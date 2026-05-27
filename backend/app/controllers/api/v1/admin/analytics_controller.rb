module Api
  module V1
    module Admin
      class AnalyticsController < ApplicationController
        before_action :require_admin!

        def index
          render json: {
            by_difficulty: Challenge.group(:difficulty).count,
            by_language: Challenge.group(:language).count,
            submissions_by_status: Submission.group(:status).count,
            daily_submissions: daily_counts,
            avg_solve_times: Challenge.where.not(avg_solve_time: nil).pluck(:title, :avg_solve_time)
          }
        end

        private

        def daily_counts
          Submission.where("created_at > ?", 30.days.ago)
                    .group("DATE(created_at)")
                    .count
        end
      end
    end
  end
end
