module Api
  module V1
    class LeaderboardController < ApplicationController
      skip_before_action :authenticate_request!

      def index
        users = User.player.order(score: :desc, xp: :desc).limit(params[:limit] || 50)
        render json: {
          leaderboard: users.map.with_index(1) do |user, rank|
            {
              rank: rank,
              username: user.username,
              score: user.score,
              xp: user.xp,
              badges_count: user.badges.count
            }
          end
        }
      end
    end
  end
end
