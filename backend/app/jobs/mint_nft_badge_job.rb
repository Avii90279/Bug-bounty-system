class MintNftBadgeJob
  include Sidekiq::Job
  sidekiq_options queue: :low

  def perform(nft_badge_id)
    nft = NftBadge.find(nft_badge_id)
    return if nft.minted?

    BlockchainService.new(nft.user).mint_nft_badge!(nft.badge)
  end
end
