# This file is auto-generated from migrations. Run: rails db:migrate

ActiveRecord::Schema[7.1].define(version: 2024_05_27_000008) do
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "username", null: false
    t.string "password_digest"
    t.string "provider"
    t.string "uid"
    t.string "avatar_url"
    t.integer "xp", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "(provider IS NOT NULL)"
  end

  create_table "challenges", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.text "buggy_code", null: false
    t.text "solution_code"
    t.integer "difficulty", default: 0, null: false
    t.integer "language", default: 0, null: false
    t.integer "xp_reward", default: 100
    t.integer "base_score", default: 1000
    t.jsonb "test_cases", default: []
    t.jsonb "metadata", default: {}
    t.boolean "ai_generated", default: false
    t.bigint "created_by_id"
    t.integer "attempts_count", default: 0
    t.integer "solves_count", default: 0
    t.float "avg_solve_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["difficulty"], name: "index_challenges_on_difficulty"
    t.index ["language"], name: "index_challenges_on_language"
    t.index ["created_by_id"], name: "index_challenges_on_created_by_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "challenge_id", null: false
    t.text "code", null: false
    t.integer "status", default: 0, null: false
    t.integer "score_awarded", default: 0
    t.integer "xp_awarded", default: 0
    t.text "ai_feedback"
    t.jsonb "evaluation_result", default: {}
    t.integer "hints_used", default: 0
    t.integer "time_taken_seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_submissions_on_user_id"
    t.index ["challenge_id"], name: "index_submissions_on_challenge_id"
    t.index ["status"], name: "index_submissions_on_status"
  end

  create_table "hints", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.integer "level", default: 1, null: false
    t.text "content", null: false
    t.integer "score_penalty", default: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id", "level"], name: "index_hints_on_challenge_id_and_level", unique: true
  end

  create_table "hint_usages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "hint_id", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.index ["user_id", "challenge_id", "hint_id"], name: "index_hint_usages_unique", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "icon"
    t.integer "criteria_type", default: 0
    t.integer "criteria_value", default: 0
    t.boolean "nft_eligible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_badges_on_slug", unique: true
  end

  create_table "user_badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.datetime "earned_at", null: false
    t.datetime "created_at", null: false
    t.index ["user_id", "badge_id"], name: "index_user_badges_on_user_id_and_badge_id", unique: true
  end

  create_table "rooms", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.bigint "host_id", null: false
    t.bigint "challenge_id"
    t.integer "status", default: 0, null: false
    t.integer "max_players", default: 8
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_rooms_on_code", unique: true
    t.index ["host_id"], name: "index_rooms_on_host_id"
  end

  create_table "room_participants", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "user_id", null: false
    t.integer "score", default: 0
    t.boolean "finished", default: false
    t.datetime "joined_at", null: false
    t.datetime "created_at", null: false
    t.index ["room_id", "user_id"], name: "index_room_participants_on_room_id_and_user_id", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address", null: false
    t.string "chain_id", default: "11155111"
    t.datetime "connected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id", unique: true
    t.index ["address"], name: "index_wallets_on_address", unique: true
  end

  create_table "nft_badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.string "token_id"
    t.string "tx_hash"
    t.string "contract_address"
    t.string "metadata_uri"
    t.integer "status", default: 0
    t.datetime "minted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_nft_badges_on_user_id"
    t.index ["token_id"], name: "index_nft_badges_on_token_id"
  end

  add_foreign_key "challenges", "users", column: "created_by_id"
  add_foreign_key "submissions", "users"
  add_foreign_key "submissions", "challenges"
  add_foreign_key "hints", "challenges"
  add_foreign_key "hint_usages", "users"
  add_foreign_key "hint_usages", "hints"
  add_foreign_key "hint_usages", "challenges"
  add_foreign_key "user_badges", "users"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "rooms", "users", column: "host_id"
  add_foreign_key "rooms", "challenges"
  add_foreign_key "room_participants", "rooms"
  add_foreign_key "room_participants", "users"
  add_foreign_key "wallets", "users"
  add_foreign_key "nft_badges", "users"
  add_foreign_key "nft_badges", "badges"
end
