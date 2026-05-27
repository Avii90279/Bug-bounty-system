class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.references :challenge, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :max_players, default: 8
      t.datetime :started_at
      t.datetime :ended_at
      t.timestamps
    end
    add_index :rooms, :code, unique: true

    create_table :room_participants do |t|
      t.references :room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, default: 0
      t.boolean :finished, default: false
      t.datetime :joined_at, null: false
      t.datetime :created_at, null: false
    end
    add_index :room_participants, [:room_id, :user_id], unique: true
  end
end
