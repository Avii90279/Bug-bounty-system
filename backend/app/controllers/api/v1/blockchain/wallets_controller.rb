module Api
  module V1
    module Blockchain
      class WalletsController < ApplicationController
        def connect
          service = BlockchainService.new(current_user)
          expected = service.wallet_message_for(current_user)

          unless params[:message].to_s == expected
            return render json: { error: "Invalid wallet message" }, status: :unauthorized
          end

          unless service.verify_wallet_signature(
            address: params[:address],
            message: params[:message],
            signature: params[:signature]
          )
            return render json: { error: "Invalid wallet signature" }, status: :unauthorized
          end

          wallet = current_user.wallet || current_user.build_wallet
          wallet.update!(address: params[:address].downcase, chain_id: params[:chain_id] || "11155111",
                         connected_at: Time.current)
          render json: { wallet: { address: wallet.address, chain_id: wallet.chain_id } }
        end

        def show
          service = BlockchainService.new(current_user)
          render json: {
            wallet: current_user.wallet&.slice(:address, :chain_id, :connected_at),
            message: service.wallet_message_for(current_user)
          }
        end
      end
    end
  end
end
