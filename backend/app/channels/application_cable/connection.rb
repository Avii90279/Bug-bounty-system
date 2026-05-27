module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token] || extract_bearer_token
      payload = JsonWebToken.decode(token)
      user = User.find_by(id: payload&.dig(:user_id))
      reject_unauthorized_connection unless user

      user
    end

    def extract_bearer_token
      request.headers["Authorization"]&.split(" ")&.last
    end
  end
end
