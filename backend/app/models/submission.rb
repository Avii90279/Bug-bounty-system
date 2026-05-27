class Submission < ApplicationRecord
  enum status: { pending: 0, evaluating: 1, passed: 2, failed: 3, error: 4 }

  belongs_to :user
  belongs_to :challenge

  validates :code, presence: true

  scope :passed, -> { where(status: :passed) }
  scope :for_user, ->(user) { where(user: user) }
end
