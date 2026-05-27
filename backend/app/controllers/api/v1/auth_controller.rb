module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request!, only: [:register, :login, :google, :refresh]

      def register
        user = User.new(register_params)
        user.save!
        tokens = JsonWebToken.tokens_for(user)
        render json: { user: UserSerializer.new(user).as_json, **tokens }, status: :created
      end

      def login
        user = User.find_by(email: params[:email]&.downcase)
        if user&.authenticate(params[:password])
          render json: { user: UserSerializer.new(user).as_json, **JsonWebToken.tokens_for(user) }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def google
        user = GoogleAuthService.new(id_token: params[:id_token]).authenticate!
        render json: { user: UserSerializer.new(user).as_json, **JsonWebToken.tokens_for(user) }
      rescue StandardError => e
        render json: { error: e.message }, status: :unauthorized
      end

      def me
        render json: { user: UserSerializer.new(current_user, include_badges: true).as_json }
      end

      def refresh
        payload = JsonWebToken.decode(params[:refresh_token])
        return render json: { error: "Invalid refresh token" }, status: :unauthorized unless payload&.dig(:user_id)

        user = User.find(payload[:user_id])
        render json: JsonWebToken.tokens_for(user)
      end

      private

      def register_params
        params.require(:user).permit(:email, :username, :password, :password_confirmation)
      end
    end
  end
end
