class CreateChallenges < ActiveRecord::Migration[7.1]
  def change
    create_table :challenges do |t|
      t.string :title, null: false
      t.text :description
      t.text :buggy_code, null: false
      t.text :solution_code
      t.integer :difficulty, default: 0, null: false
      t.integer :language, default: 0, null: false
      t.integer :xp_reward, default: 100
      t.integer :base_score, default: 1000
      t.jsonb :test_cases, default: []
      t.jsonb :metadata, default: {}
      t.boolean :ai_generated, default: false
      t.references :created_by, foreign_key: { to_table: :users }
      t.integer :attempts_count, default: 0
      t.integer :solves_count, default: 0
      t.float :avg_solve_time
      t.timestamps
    end
    add_index :challenges, :difficulty
    add_index :challenges, :language
  end
end
