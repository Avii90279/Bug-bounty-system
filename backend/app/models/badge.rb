class Badge < ApplicationRecord
  enum criteria_type: {
    solves_count: 0,
    xp_total: 1,
    fast_solve: 2,
    no_hints_streak: 3,
    languages_solved: 4,
    expert_solves: 5
  }

  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges
  has_many :nft_badges, dependent: :destroy

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
end
