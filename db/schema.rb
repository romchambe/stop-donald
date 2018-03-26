# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180324122958) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "game_invites_invitees", id: false, force: :cascade do |t|
    t.integer "game_invite_id", null: false
    t.integer "invitee_id", null: false
    t.index ["game_invite_id", "invitee_id"], name: "index_game_invites_invitees_on_game_invite_id_and_invitee_id"
    t.index ["invitee_id", "game_invite_id"], name: "index_game_invites_invitees_on_invitee_id_and_game_invite_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "turn_number"
    t.text "us_army_forces"
    t.text "rebels_forces"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.string "status"
    t.text "cities"
    t.text "launch_sites"
    t.index ["creator_id"], name: "index_games_on_creator_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.string "country"
    t.string "username"
    t.integer "lost_cities"
    t.integer "lost_launch_sites"
    t.text "launch_sites"
    t.text "available_forces"
    t.text "engaged_forces"
    t.text "spies"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
