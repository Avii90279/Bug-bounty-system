module Api
  module V1
    class UsersController < ApplicationController
      def show
        user = User.find(params[:id])
        render json: UserSerializer.new(user, include_badges: true, public: true).as_json
      end

      def update
        current_user.update!(user_params)
        render json: UserSerializer.new(current_user).as_json
      end

      private

      def user_params
        params.require(:user).permit(:username, :avatar_url)
      end
    end
  end
end
