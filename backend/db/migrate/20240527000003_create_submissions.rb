class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :challenge, null: false, foreign_key: true
      t.text :code, null: false
      t.integer :status, default: 0, null: false
      t.integer :score_awarded, default: 0
      t.integer :xp_awarded, default: 0
      t.text :ai_feedback
      t.jsonb :evaluation_result, default: {}
      t.integer :hints_used, default: 0
      t.integer :time_taken_seconds
      t.timestamps
    end
    add_index :submissions, :status
  end
end
