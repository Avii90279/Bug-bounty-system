module Api
  module V1
    class ChallengesController < ApplicationController
      before_action :set_challenge, only: [:show, :submit, :hint, :analytics]
      skip_before_action :authenticate_request!, only: [:index, :show]
      before_action :authenticate_request_optional, only: [:index, :show]

      def index
        challenges = Challenge.recent
        challenges = challenges.by_difficulty(params[:difficulty]) if params[:difficulty]
        challenges = challenges.by_language(params[:language]) if params[:language]
        challenges = challenges.page(params[:page]).per(params[:per_page] || 20)

        render json: {
          challenges: challenges.map { |c| ChallengeSerializer.new(c).as_json },
          meta: pagination_meta(challenges)
        }
      end

      def show
        render json: ChallengeSerializer.new(@challenge, include_code: true, user: current_user).as_json
      end

      def create
        require_admin!
        challenge = Challenge.create!(challenge_params.merge(created_by: current_user))
        render json: ChallengeSerializer.new(challenge, include_code: true).as_json, status: :created
      end

      def generate
        result = AiChallengeGenerator.new(
          difficulty: params[:difficulty] || "medium",
          language: params[:language] || "javascript",
          topic: params[:topic]
        ).generate!

        challenge = Challenge.create!(
          title: result[:title],
          description: result[:description],
          buggy_code: result[:buggy_code],
          solution_code: result[:solution_code],
          test_cases: result[:test_cases] || [],
          difficulty: params[:difficulty] || "medium",
          language: params[:language] || "javascript",
          ai_generated: true,
          created_by: current_user,
          xp_reward: xp_for_difficulty(params[:difficulty]),
          base_score: score_for_difficulty(params[:difficulty])
        )

        (result[:hints] || []).each do |h|
          challenge.hints.create!(level: h[:level] || h["level"], content: h[:content] || h["content"],
                                  score_penalty: h[:score_penalty] || h["score_penalty"] || 100)
        end

        render json: ChallengeSerializer.new(challenge, include_code: true).as_json, status: :created
      end

      def submit
        @challenge.record_attempt!
        submission = current_user.submissions.create!(
          challenge: @challenge,
          code: params[:code],
          status: :evaluating,
          hints_used: hint_penalty_count,
          time_taken_seconds: params[:time_taken_seconds]
        )

        EvaluateSubmissionJob.perform_async(submission.id)

        render json: { submission: SubmissionSerializer.new(submission).as_json, message: "Evaluation started" },
               status: :accepted
      end

      def hint
        hint = @challenge.hints.find_by!(level: params[:level])
        usage = current_user.hint_usages.find_or_create_by!(hint: hint, challenge: @challenge)
        render json: {
          hint: { level: hint.level, content: hint.content, score_penalty: hint.score_penalty },
          total_penalty: current_user.hint_usages.where(challenge: @challenge).joins(:hint).sum("hints.score_penalty")
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Hint not found" }, status: :not_found
      end

      def analytics
        require_admin!
        render json: { challenge_id: @challenge.id, analytics: @challenge.analytics }
      end

      private

      def set_challenge
        @challenge = Challenge.find(params[:id])
      end

      def challenge_params
        params.require(:challenge).permit(:title, :description, :buggy_code, :difficulty, :language, :xp_reward, :base_score)
      end

      def hint_penalty_count
        current_user.hint_usages.where(challenge: @challenge).count
      end

      def xp_for_difficulty(d)
        { "easy" => 50, "medium" => 150, "hard" => 300, "expert" => 500 }[d] || 100
      end

      def score_for_difficulty(d)
        { "easy" => 500, "medium" => 1200, "hard" => 2000, "expert" => 3500 }[d] || 1000
      end

      def pagination_meta(collection)
        { page: collection.current_page, total_pages: collection.total_pages, total_count: collection.total_count }
      rescue NoMethodError
        { page: 1, total_pages: 1, total_count: collection.size }
      end
    end
  end
end
