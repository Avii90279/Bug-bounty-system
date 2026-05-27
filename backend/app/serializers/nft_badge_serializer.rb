class NftBadgeSerializer
  def initialize(nft)
    @nft = nft
  end

  def as_json
    {
      id: @nft.id,
      badge: BadgeSerializer.new(@nft.badge).as_json,
      token_id: @nft.token_id,
      tx_hash: @nft.tx_hash,
      contract_address: @nft.contract_address,
      metadata_uri: @nft.metadata_uri,
      status: @nft.status,
      minted_at: @nft.minted_at
    }
  end
end
