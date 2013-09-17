# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130625202241) do

  create_table "activity_logs", force: true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_checks", force: true do |t|
    t.integer  "assignment_repository_id"
    t.integer  "number"
    t.integer  "status"
    t.decimal  "overall_score",            precision: 16, scale: 8
    t.text     "extra"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commit_sha"
  end

  create_table "assignment_offerings", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "course_offering_id"
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.datetime "due_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", force: true do |t|
    t.integer  "creator_id"
    t.integer  "course_id"
    t.string   "short_name"
    t.string   "long_name"
    t.text     "brief_summary"
    t.text     "description"
    t.string   "url_part"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "resource_key"
  end

  add_index "assignments", ["resource_key"], name: "index_assignments_on_resource_key", using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "check_outcomes", force: true do |t|
    t.integer  "assignment_check_id"
    t.string   "name"
    t.string   "description"
    t.string   "category"
    t.integer  "position"
    t.decimal  "score",               precision: 16, scale: 8
    t.decimal  "possible_score",      precision: 16, scale: 8
    t.text     "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_enrollments", force: true do |t|
    t.integer "user_id"
    t.integer "course_offering_id"
    t.integer "course_role_id"
  end

  add_index "course_enrollments", ["course_offering_id"], name: "index_course_enrollments_on_course_offering_id", using: :btree
  add_index "course_enrollments", ["course_role_id"], name: "index_course_enrollments_on_course_role_id", using: :btree
  add_index "course_enrollments", ["user_id", "course_offering_id"], name: "index_course_enrollments_on_user_id_and_course_offering_id", unique: true, using: :btree
  add_index "course_enrollments", ["user_id"], name: "index_course_enrollments_on_user_id", using: :btree

  create_table "course_offerings", force: true do |t|
    t.integer  "course_id"
    t.integer  "term_id"
    t.string   "short_label"
    t.string   "long_label"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "self_enrollment_allowed"
  end

  create_table "course_roles", force: true do |t|
    t.string  "name",                       default: "",    null: false
    t.boolean "can_manage_course",          default: false, null: false
    t.boolean "can_manage_assignments",     default: false, null: false
    t.boolean "can_grade_submissions",      default: false, null: false
    t.boolean "can_view_other_submissions", default: false, null: false
    t.boolean "builtin",                    default: false, null: false
  end

  create_table "courses", force: true do |t|
    t.string   "name"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "url_part"
    t.integer  "default_environment_id"
  end

  create_table "environments", force: true do |t|
    t.string   "name"
    t.text     "preamble"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "global_roles", force: true do |t|
    t.string  "name",                          default: "",    null: false
    t.boolean "can_create_courses",            default: false, null: false
    t.boolean "can_manage_all_courses",        default: false, null: false
    t.boolean "can_edit_system_configuration", default: false, null: false
    t.boolean "builtin",                       default: false, null: false
  end

  create_table "media_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.string   "file"
    t.string   "content_type"
    t.integer  "file_size"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.string   "domain"
    t.string   "display_name"
    t.string   "abbreviation"
    t.string   "url_part"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["abbreviation"], name: "index_organizations_on_abbreviation", unique: true, using: :btree
  add_index "organizations", ["domain"], name: "index_organizations_on_domain", unique: true, using: :btree
  add_index "organizations", ["url_part"], name: "index_organizations_on_url_part", unique: true, using: :btree

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "repositories", force: true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignment_offering_id"
    t.integer  "course_offering_id"
    t.text     "description"
    t.integer  "source_repository_id"
    t.string   "name"
    t.integer  "assignment_id"
    t.integer  "environment_id"
  end

  create_table "system_configurations", force: true do |t|
    t.string   "storage_path"
    t.string   "work_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "terms", force: true do |t|
    t.integer  "year"
    t.integer  "season"
    t.date     "starts_on"
    t.date     "ends_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "global_role_id"
    t.string   "resource_key"
    t.string   "full_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["resource_key"], name: "index_users_on_resource_key", using: :btree

end
