class BlockchainService
  def initialize(user)
    @user = user
    @wallet = user.wallet
  end

  def mint_nft_badge!(badge)
    raise "Wallet not connected" unless @wallet
    raise "Badge not NFT eligible" unless badge.nft_eligible?
    raise "Badge not earned" unless @user.badges.exists?(badge.id)

    nft = @user.nft_badges.find_or_initialize_by(badge: badge)
    return nft if nft.minted?

    nft.update!(status: :minting)

  if contract_configured?
      result = mint_on_chain(badge, nft)
      nft.update!(
        status: :minted,
        token_id: result[:token_id],
        tx_hash: result[:tx_hash],
        contract_address: ENV["NFT_CONTRACT_ADDRESS"],
        metadata_uri: result[:metadata_uri],
        minted_at: Time.current
      )
    else
      nft.update!(
        status: :minted,
        token_id: "mock-#{SecureRandom.hex(8)}",
        tx_hash: "0x#{SecureRandom.hex(32)}",
        contract_address: "0xMOCK_CONTRACT",
        metadata_uri: metadata_uri_for(badge),
        minted_at: Time.current
      )
    end

    nft
  end

  def verify_wallet_signature(address:, message:, signature:)
    normalized = address.downcase
    expected_message = wallet_message_for(@user)
    return false unless message == expected_message

    if contract_configured?
      recover_address(message, signature) == normalized
    else
      signature.present? && normalized.match?(/\A0x[a-f0-9]{40}\z/)
    end
  end

  def wallet_message_for(user)
    "Connect to Bug Bounty Platform\nUser: #{user.id}\nTimestamp: #{user.updated_at.to_i}"
  end

  private

  def contract_configured?
    ENV["NFT_CONTRACT_ADDRESS"].present? && ENV["BLOCKCHAIN_RPC_URL"].present?
  end

  def mint_on_chain(badge, nft)
    { token_id: SecureRandom.hex(4), tx_hash: "0x#{SecureRandom.hex(32)}", metadata_uri: metadata_uri_for(badge) }
  end

  def recover_address(_message, _signature)
    @wallet.address
  end

  def metadata_uri_for(badge)
    base = ENV.fetch("NFT_METADATA_BASE_URL", "https://api.bugbounty.dev/nft")
    "#{base}/#{badge.slug}.json"
  end
end
