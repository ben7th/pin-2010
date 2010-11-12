class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "bugs", :force => true do |t|
      t.string   "kind"
      t.string   "content"
      t.integer  "user_id"
      t.string   "user_ip"
      t.string   "attachment_file_name"
      t.string   "attachment_content_type"
      t.integer  "attachment_file_size"
      t.datetime "attachment_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "handled",                 :default => false
      t.boolean  "closed",                  :default => false
      t.string   "user_agent"
    end
    
    create_table "comments", :force => true do |t|
      t.text     "content"
      t.integer  "creator_id"
      t.integer  "markable_id"
      t.string   "markable_type"
      t.integer  "reply_to"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "favorites", :force => true do |t|
      t.integer  "favorable_id"
      t.string   "favorable_type"
      t.integer  "user_id"
      t.integer  "num"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
