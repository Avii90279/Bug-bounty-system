module Api
  module V1
    class BadgesController < ApplicationController
      def index
        badges = Badge.all
        earned_ids = current_user.badges.pluck(:id)
        render json: {
          badges: badges.map do |b|
            BadgeSerializer.new(b).as_json.merge(earned: earned_ids.include?(b.id))
          end
        }
      end
    end
  end
end
