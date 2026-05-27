module Api
  module V1
    class SubmissionsController < ApplicationController
      def index
        submissions = current_user.submissions.includes(:challenge).order(created_at: :desc)
        submissions = submissions.page(params[:page]).per(20) if submissions.respond_to?(:page)
        render json: { submissions: submissions.map { |s| SubmissionSerializer.new(s).as_json } }
      end

      def show
        submission = current_user.submissions.find(params[:id])
        render json: SubmissionSerializer.new(submission).as_json
      end
    end
  end
end
