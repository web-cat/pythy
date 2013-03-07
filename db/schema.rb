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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130111190807) do

  create_table "activity_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.text     "info"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assignment_checks", :force => true do |t|
    t.integer  "assignment_repository_id"
    t.integer  "number"
    t.integer  "status"
    t.decimal  "overall_score",            :precision => 16, :scale => 8
    t.text     "extra"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  create_table "assignment_offerings", :force => true do |t|
    t.integer  "assignment_id"
    t.integer  "course_offering_id"
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.datetime "due_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "assignments", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "course_id"
    t.string   "short_name"
    t.string   "long_name"
    t.text     "brief_summary"
    t.text     "description"
    t.string   "url_part"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "check_outcomes", :force => true do |t|
    t.integer  "assignment_check_id"
    t.string   "name"
    t.string   "description"
    t.string   "category"
    t.integer  "position"
    t.decimal  "score",               :precision => 16, :scale => 8
    t.decimal  "possible_score",      :precision => 16, :scale => 8
    t.text     "detail"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  create_table "course_enrollments", :force => true do |t|
    t.integer "user_id"
    t.integer "course_offering_id"
    t.integer "course_role_id"
  end

  add_index "course_enrollments", ["course_offering_id"], :name => "index_course_enrollments_on_course_offering_id"
  add_index "course_enrollments", ["course_role_id"], :name => "index_course_enrollments_on_course_role_id"
  add_index "course_enrollments", ["user_id", "course_offering_id"], :name => "index_course_enrollments_on_user_id_and_course_offering_id", :unique => true
  add_index "course_enrollments", ["user_id"], :name => "index_course_enrollments_on_user_id"

  create_table "course_offerings", :force => true do |t|
    t.integer  "course_id"
    t.integer  "term_id"
    t.integer  "crn"
    t.string   "label"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "course_roles", :force => true do |t|
    t.string  "name",                                          :null => false
    t.boolean "can_manage_course",          :default => false, :null => false
    t.boolean "can_manage_assignments",     :default => false, :null => false
    t.boolean "can_grade_submissions",      :default => false, :null => false
    t.boolean "can_view_other_submissions", :default => false, :null => false
    t.boolean "builtin",                    :default => false, :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "department_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "departments", :force => true do |t|
    t.integer  "institution_id"
    t.string   "name"
    t.string   "abbreviation"
    t.string   "url_part"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "global_roles", :force => true do |t|
    t.string  "name",                                             :null => false
    t.boolean "can_create_courses",            :default => false, :null => false
    t.boolean "can_manage_all_courses",        :default => false, :null => false
    t.boolean "can_edit_system_configuration", :default => false, :null => false
    t.boolean "builtin",                       :default => false, :null => false
  end

  create_table "institutions", :force => true do |t|
    t.string   "display_name"
    t.string   "domain"
    t.string   "abbreviation"
    t.string   "url_part"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "institutions", ["abbreviation"], :name => "index_institutions_on_abbreviation", :unique => true
  add_index "institutions", ["domain"], :name => "index_institutions_on_domain", :unique => true

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "repositories", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "assignment_offering_id"
    t.integer  "course_offering_id"
    t.integer  "assignment_id"
    t.integer  "source_repository_id"
  end

  create_table "system_configurations", :force => true do |t|
    t.string   "storage_path", :default => ""
    t.string   "work_path",    :default => ""
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "terms", :force => true do |t|
    t.integer  "year"
    t.integer  "season"
    t.date     "starts_on"
    t.date     "ends_on"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "institution_id"
    t.integer  "global_role_id"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
