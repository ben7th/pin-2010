class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "feelings", :force => true do |t|
      t.integer  "feelable_id"
      t.string   "feelable_type"
      t.integer  "user_id"
      t.string   "evaluation"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "shares", :force => true do |t|
      t.integer  "shareable_id"
      t.integer  "creator_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "shareable_type"
      t.text     "content"
      t.string   "kind",            :default => "TALK"
      t.integer  "last_forward_id"
      t.integer  "entry_id"
    end

    add_index "shares", ["creator_id"], :name => "index_shares_on_creator_id"
    add_index "shares", ["shareable_id"], :name => "index_shares_on_entry_id"

    create_table "short_urls", :force => true do |t|
      t.string   "url"
      t.string   "code"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "entries", :force => true do |t|
      t.integer  "user_id"
      t.integer  "resource_id"
      t.string   "resource_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.integer  "host_id"
      t.string   "host_type"
      t.string   "from"
      t.boolean  "forbidden"
    end

    add_index "entries", ["resource_id", "resource_type"], :name => "index_resource_entries_on_resource_id_and_resource_type"
    add_index "entries", ["user_id"], :name => "index_resource_entries_on_user_id"

    create_table "file_entries", :force => true do |t|
      t.string   "title"
      t.string   "content_file_name"
      t.string   "content_content_type"
      t.integer  "content_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "subject"
      t.string   "detail"
    end

    create_table "bookmark_entries", :force => true do |t|
      t.string   "url"
      t.string   "site"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "snapshot"
      t.string   "image_src"
      t.string   "video_src"
    end

    create_table "usings", :force => true do |t|
      t.integer  "share_id"
      t.integer  "entry_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "usings", ["entry_id"], :name => "index_usings_on_entry_id"
    add_index "usings", ["share_id"], :name => "index_usings_on_share_id"

    create_table "contactings", :force => true do |t|
      t.integer  "host_id"
      t.integer  "contact_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "show_share"
    end

    add_index "contactings", ["contact_id"], :name => "index_contacts_on_friend_id"
    add_index "contactings", ["host_id"], :name => "index_contacts_on_host_id"
  end

  def self.down
  end
end
