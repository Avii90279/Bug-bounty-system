class NftBadge < ApplicationRecord
  enum status: { pending: 0, minting: 1, minted: 2, failed: 3 }

  belongs_to :user
  belongs_to :badge

  validates :badge_id, uniqueness: { scope: :user_id, message: "NFT already minted for this badge" }
end
