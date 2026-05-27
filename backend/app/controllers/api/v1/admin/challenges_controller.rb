module Api
  module V1
    module Admin
      class ChallengesController < ApplicationController
        before_action :require_admin!

        def index
          challenges = Challenge.order(created_at: :desc)
          render json: { challenges: challenges.map { |c| ChallengeSerializer.new(c).as_json } }
        end

        def destroy
          Challenge.find(params[:id]).destroy!
          head :no_content
        end
      end
    end
  end
end
