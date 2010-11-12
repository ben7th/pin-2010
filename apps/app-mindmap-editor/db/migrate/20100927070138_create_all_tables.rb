class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "comments", :force => true do |t|
      t.string   "title",            :limit => 50, :default => ""
      t.string   "comment",                        :default => ""
      t.datetime "created_at",                                     :null => false
      t.integer  "commentable_id",                 :default => 0,  :null => false
      t.string   "commentable_type", :limit => 15, :default => "", :null => false
      t.integer  "user_id",                        :default => 0,  :null => false
    end

    add_index "comments", ["user_id"], :name => "fk_comments_user"

    create_table "history_records", :force => true do |t|
      t.string   "kind"
      t.string   "params_json"
      t.text     "struct"
      t.integer  "mindmap_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "mindmaps", :force => true do |t|
      t.integer  "user_id",                                                 :null => false
      t.string   "title",                                   :default => "", :null => false
      t.string   "description"
      t.text     "struct",            :limit => 2147483647
      t.string   "logo_file_name"
      t.float    "score"
      t.boolean  "private"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.integer  "weight"
      t.text     "content"
      t.integer  "clone_from"
    end

    add_index "mindmaps", ["user_id"], :name => "index_pinmaps_on_user_id"

    create_table "nodes", :force => true do |t|
      t.integer  "mindmap_id",                       :null => false
      t.integer  "local_id"
      t.text     "note",       :limit => 2147483647
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "nodes", ["mindmap_id", "local_id"], :name => "index_nodes_on_mindmap_id_and_local_id"
    add_index "nodes", ["mindmap_id"], :name => "index_nodes_on_mindmap_id"

    create_table "rates", :force => true do |t|
      t.integer  "user_id"
      t.integer  "rateable_id"
      t.string   "rateable_type", :limit => 30
      t.integer  "rate"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "rates", ["rateable_id"], :name => "index_rates_on_rateable_id"
    add_index "rates", ["user_id"], :name => "index_rates_on_user_id"

    create_table "snapshots", :force => true do |t|
      t.integer  "mindmap_id"
      t.string   "title"
      t.text     "struct"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

    create_table "tags", :force => true do |t|
      t.string "name"
    end

    create_table "visit_counters", :force => true do |t|
      t.integer  "resource_id",                   :null => false
      t.string   "resource_type", :default => "", :null => false
      t.integer  "visit_count",   :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "visit_counters", ["resource_id", "resource_type"], :name => "index_visit_counters_on_resource_id_and_resource_type"

  end

  def self.down
  end
end
