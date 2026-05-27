class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :username, null: false
      t.string :password_digest
      t.string :provider
      t.string :uid
      t.string :avatar_url
      t.integer :xp, default: 0, null: false
      t.integer :score, default: 0, null: false
      t.integer :role, default: 0, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, [:provider, :uid], unique: true, where: "provider IS NOT NULL"
  end
end
