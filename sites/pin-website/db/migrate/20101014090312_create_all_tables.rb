class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "web_sites", :force => true do |t|
      t.string   "domain"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "page_rank"
      t.string   "title"
      t.string   "key_words"
      t.string   "description"
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

    create_table "feelings", :force => true do |t|
      t.integer  "feelable_id"
      t.string   "feelable_type"
      t.integer  "user_id"
      t.string   "evaluation"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "introductions", :force => true do |t|
      t.integer  "user_id"
      t.integer  "introductable_id"
      t.boolean  "checked"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "introductable_type"
    end
  end

  def self.down
  end
end
