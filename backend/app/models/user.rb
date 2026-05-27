class User < ApplicationRecord
  has_secure_password validations: false

  enum role: { player: 0, admin: 1 }

  has_many :submissions, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  has_many :hint_usages, dependent: :destroy
  has_many :hosted_rooms, class_name: "Room", foreign_key: :host_id, dependent: :destroy
  has_many :room_participants, dependent: :destroy
  has_many :rooms, through: :room_participants
  has_one :wallet, dependent: :destroy
  has_many :nft_badges, dependent: :destroy
  has_many :created_challenges, class_name: "Challenge", foreign_key: :created_by_id

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validate :password_or_oauth_present, on: :create

  def oauth_user?
    provider.present?
  end

  def award_xp!(amount)
    increment!(:xp, amount)
    check_level_badges!
  end

  def award_score!(amount)
    increment!(:score, amount)
  end

  def admin?
    role == "admin" || role == 1
  end

  private

  def password_or_oauth_present
    return if oauth_user? || password_digest.present?

    errors.add(:password, "can't be blank for email registration")
  end

  def check_level_badges!
    BadgeAwardService.new(self).check_all!
  end
end
