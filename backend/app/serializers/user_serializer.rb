class UserSerializer
  def initialize(user, include_badges: false, public: false)
    @user = user
    @include_badges = include_badges
    @public = public
  end

  def as_json
    data = {
      id: @user.id,
      username: @user.username,
      avatar_url: @user.avatar_url,
      xp: @user.xp,
      score: @user.score,
      role: @user.role
    }
    data[:email] = @user.email unless @public
    if @include_badges
      data[:badges] = @user.user_badges.includes(:badge).map do |ub|
        { slug: ub.badge.slug, name: ub.badge.name, icon: ub.badge.icon, earned_at: ub.earned_at }
      end
    end
    data
  end
end
