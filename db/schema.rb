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

ActiveRecord::Schema[7.0].define(version: 2022_04_13_151911) do
  create_table "board_game_records", force: :cascade do |t|
    t.integer "board_game_id", null: false
    t.string "player"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.index ["board_game_id"], name: "index_board_game_records_on_board_game_id"
  end

  create_table "board_games", force: :cascade do |t|
    t.text "content"
    t.integer "status"
    t.string "a"
    t.string "b"
    t.string "c"
    t.string "d"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "a_hand"
    t.string "b_hand"
    t.string "c_hand"
    t.string "d_hand"
    t.string "current_player"
    t.string "last_player"
    t.string "last_cards"
    t.integer "team"
    t.string "team_a"
    t.string "team_b"
    t.string "shose_owner"
    t.string "show_team"
    t.integer "show"
    t.string "show_a"
    t.string "show_b"
    t.string "show_c"
    t.string "show_d"
    t.integer "a_result"
    t.integer "b_result"
    t.integer "c_result"
    t.integer "d_result"
  end

  create_table "card_tables", force: :cascade do |t|
    t.integer "board_game_id"
    t.integer "status"
    t.string "a"
    t.string "b"
    t.string "c"
    t.string "d"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "a_score"
    t.integer "b_score"
    t.integer "c_score"
    t.integer "d_score"
    t.integer "prepared"
    t.index ["board_game_id"], name: "index_card_tables_on_board_game_id"
  end

  add_foreign_key "board_game_records", "board_games"
  add_foreign_key "card_tables", "board_games"
end
