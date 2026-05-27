module Api
  module V1
    module Blockchain
      class NftBadgesController < ApplicationController
        def index
          nfts = current_user.nft_badges.includes(:badge)
          render json: { nft_badges: nfts.map { |n| NftBadgeSerializer.new(n).as_json } }
        end

        def mint
          badge = Badge.find(params[:badge_id])
          nft = BlockchainService.new(current_user).mint_nft_badge!(badge)
          MintNftBadgeJob.perform_async(nft.id) if nft.pending? || nft.minting?
          render json: NftBadgeSerializer.new(nft).as_json
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
