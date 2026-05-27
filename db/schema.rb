# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_26_011451) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "fielding_positions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "inning"
    t.integer "player_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_fielding_positions_on_game_id"
    t.index ["player_id"], name: "index_fielding_positions_on_player_id"
  end

  create_table "game_rosters", force: :cascade do |t|
    t.boolean "available"
    t.integer "batting_order"
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "player_id", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_rosters_on_game_id"
    t.index ["player_id"], name: "index_game_rosters_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date"
    t.boolean "is_home", null: false
    t.string "opponent"
    t.integer "season_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_games_on_season_id"
  end

  create_table "inning_scores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "inning", null: false
    t.boolean "our_half"
    t.integer "runs", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_inning_scores_on_game_id"
  end

  create_table "plate_appearances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "inning"
    t.integer "outs_before", default: 0
    t.integer "player_id", null: false
    t.integer "rbi"
    t.integer "result"
    t.boolean "top_inning", default: true
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_plate_appearances_on_game_id"
    t.index ["player_id"], name: "index_plate_appearances_on_player_id"
  end

  create_table "player_positions", force: :cascade do |t|
    t.integer "cost"
    t.integer "player_team_id"
    t.integer "position"
    t.index ["player_team_id"], name: "index_player_positions_on_player_team_id"
  end

  create_table "player_teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "player_id", null: false
    t.integer "season_id", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_player_teams_on_player_id"
    t.index ["season_id"], name: "index_player_teams_on_season_id"
    t.index ["team_id"], name: "index_player_teams_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.integer "jersey_number"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "plate_appearance_id", null: false
    t.integer "player_id", null: false
    t.datetime "updated_at", null: false
    t.index ["plate_appearance_id"], name: "index_runs_on_plate_appearance_id"
    t.index ["player_id"], name: "index_runs_on_player_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "season"
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_seasons_on_team_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "season"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "fielding_positions", "games"
  add_foreign_key "fielding_positions", "players"
  add_foreign_key "game_rosters", "games"
  add_foreign_key "game_rosters", "players"
  add_foreign_key "inning_scores", "games"
  add_foreign_key "plate_appearances", "games"
  add_foreign_key "plate_appearances", "players"
  add_foreign_key "player_teams", "players"
  add_foreign_key "player_teams", "seasons"
  add_foreign_key "player_teams", "teams"
  add_foreign_key "runs", "plate_appearances"
  add_foreign_key "runs", "players"
  add_foreign_key "seasons", "teams"
  add_foreign_key "sessions", "users"
end
