class Wallet < ApplicationRecord
  belongs_to :user

  validates :address, presence: true, uniqueness: true
  validates :user_id, uniqueness: true

  before_validation :normalize_address

  private

  def normalize_address
    self.address = address&.downcase
  end
end
