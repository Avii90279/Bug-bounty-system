class Hint < ApplicationRecord
  belongs_to :challenge
  has_many :hint_usages, dependent: :destroy

  validates :level, :content, presence: true
  validates :level, uniqueness: { scope: :challenge_id }
end
