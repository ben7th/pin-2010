class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "image_caches", :force => true do |t|
      t.integer  "mindmap_id"
      t.string   "size_param"
      t.string   "img_file_name"
      t.string   "img_content_type"
      t.integer  "img_file_size"
      t.datetime "img_updated_at"
      t.datetime "mindmap_last_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
