class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_request!

  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable

  private

  def authenticate_request!
    token = extract_token
  return render json: { error: "Unauthorized" }, status: :unauthorized unless token

    payload = JsonWebToken.decode(token)
  return render json: { error: "Invalid or expired token" }, status: :unauthorized unless payload&.dig(:user_id)

    @current_user = User.find_by(id: payload[:user_id])
    render json: { error: "User not found" }, status: :unauthorized unless @current_user
  end

  def authenticate_request_optional
    token = extract_token
    return unless token

    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload[:user_id]) if payload&.dig(:user_id)
  end

  def extract_token
    auth = request.headers["Authorization"]
    return auth.split(" ").last if auth&.start_with?("Bearer ")

    params[:token]
  end

  def require_admin!
    render json: { error: "Admin access required" }, status: :forbidden unless current_user&.admin?
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
end
