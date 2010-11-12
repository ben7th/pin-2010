class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "apps", :force => true do |t|
      t.string   "name"
      t.string   "title"
      t.string   "callback_url"
      t.integer  "port",              :default => 80
      t.string   "secret_key"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.string   "developer"
      t.text     "subject"
    end

    add_index "apps", ["name"], :name => "index_apps_on_name"

    create_table "installings", :force => true do |t|
      t.integer  "user_id"
      t.integer  "app_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_default"
      t.boolean  "usually_used"
    end

    add_index "installings", ["app_id"], :name => "index_installings_on_app_id"
    add_index "installings", ["user_id"], :name => "index_installings_on_user_id"
  end

  def self.down
  end
end
