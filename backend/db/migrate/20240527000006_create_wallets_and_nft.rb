class CreateWalletsAndNft < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :address, null: false
      t.string :chain_id, default: "11155111"
      t.datetime :connected_at, null: false
      t.timestamps
    end
    add_index :wallets, :user_id, unique: true
    add_index :wallets, :address, unique: true

    create_table :nft_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true
      t.string :token_id
      t.string :tx_hash
      t.string :contract_address
      t.string :metadata_uri
      t.integer :status, default: 0
      t.datetime :minted_at
      t.timestamps
    end
    add_index :nft_badges, :token_id
  end
end
