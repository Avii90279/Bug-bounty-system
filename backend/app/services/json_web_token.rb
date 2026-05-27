class JsonWebToken
  SECRET = ENV.fetch("JWT_SECRET") { Rails.application.credentials.secret_key_base }
  EXPIRY = 24.hours
  REFRESH_EXPIRY = 7.days

  class << self
    def encode(payload, exp = EXPIRY.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET, "HS256")
    end

    def decode(token)
      body = JWT.decode(token, SECRET, true, algorithm: "HS256")[0]
      HashWithIndifferentAccess.new(body)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    def tokens_for(user)
      {
        access_token: encode({ user_id: user.id, type: "access" }),
        refresh_token: encode({ user_id: user.id, type: "refresh" }, REFRESH_EXPIRY.from_now)
      }
    end
  end
end
