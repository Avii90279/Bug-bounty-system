class GoogleAuthService
  GOOGLE_TOKEN_INFO = "https://oauth2.googleapis.com/tokeninfo"

  def initialize(id_token:)
    @id_token = id_token
  end

  def authenticate!
    payload = verify_token
    find_or_create_user(payload)
  end

  private

  def verify_token
    response = Faraday.get(GOOGLE_TOKEN_INFO, { id_token: @id_token })
    raise "Invalid Google token" unless response.success?

    data = JSON.parse(response.body)
    raise "Invalid audience" if ENV["GOOGLE_CLIENT_ID"].present? && data["aud"] != ENV["GOOGLE_CLIENT_ID"]

    data
  end

  def find_or_create_user(payload)
    user = User.find_by(provider: "google", uid: payload["sub"])
    user ||= User.find_by(email: payload["email"])

    if user
      user.update!(provider: "google", uid: payload["sub"], avatar_url: payload["picture"]) unless user.oauth_user?
      user
    else
      username = generate_username(payload["email"])
      User.create!(
        email: payload["email"],
        username: username,
        provider: "google",
        uid: payload["sub"],
        avatar_url: payload["picture"]
      )
    end
  end

  def generate_username(email)
    base = email.split("@").first.gsub(/[^a-zA-Z0-9_]/, "")[0, 20]
    candidate = base
    suffix = 1
    while User.exists?(username: candidate)
      candidate = "#{base}#{suffix}"
      suffix += 1
    end
    candidate
  end
end
