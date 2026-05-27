class CreateHintsAndBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :hints do |t|
      t.references :challenge, null: false, foreign_key: true
      t.integer :level, default: 1, null: false
      t.text :content, null: false
      t.integer :score_penalty, default: 100
      t.timestamps
    end
    add_index :hints, [:challenge_id, :level], unique: true

    create_table :hint_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hint, null: false, foreign_key: true
      t.references :challenge, null: false, foreign_key: true
      t.datetime :created_at, null: false
    end
    add_index :hint_usages, [:user_id, :challenge_id, :hint_id], unique: true, name: "index_hint_usages_unique"

    create_table :badges do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon
      t.integer :criteria_type, default: 0
      t.integer :criteria_value, default: 0
      t.boolean :nft_eligible, default: false
      t.timestamps
    end
    add_index :badges, :slug, unique: true

    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true
      t.datetime :earned_at, null: false
      t.datetime :created_at, null: false
    end
    add_index :user_badges, [:user_id, :badge_id], unique: true
  end
end
