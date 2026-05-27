module Api
  module V1
    module Admin
      class UsersController < ApplicationController
        before_action :require_admin!

        def index
          users = User.order(created_at: :desc).limit(100)
          render json: { users: users.map { |u| UserSerializer.new(u, public: true).as_json } }
        end

        def show
          user = User.find(params[:id])
          render json: UserSerializer.new(user, include_badges: true).as_json
        end

        def update
          user = User.find(params[:id])
          user.update!(params.permit(:role))
          render json: UserSerializer.new(user).as_json
        end
      end
    end
  end
end
