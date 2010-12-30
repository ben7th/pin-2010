class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "online_records", :force => true do |t|
      t.integer  "user_id"
      t.string   "key"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "online_records", ["key"], :name => "index_online_records_on_key"
    add_index "online_records", ["user_id"], :name => "index_online_records_on_user_id"

    create_table "preferences", :force => true do |t|
      t.integer  "user_id",                          :null => false
      t.boolean  "auto_popup_msg", :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "show_tooltip",   :default => true
      t.string   "theme"
    end
    add_index "preferences", ["user_id"], :name => "index_preferences_on_user_id"

    create_table "users", :force => true do |t|
      t.string   "name",                      :default => "", :null => false
      t.string   "hashed_password",           :default => "", :null => false
      t.string   "salt",                      :default => "", :null => false
      t.string   "email",                     :default => "", :null => false
      t.string   "sign"
      t.string   "activation_code"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "activated_at"
      t.string   "reset_password_code"
      t.datetime "reset_password_code_until"
      t.datetime "last_login_time"
    end
  end

  def self.down
  end
end