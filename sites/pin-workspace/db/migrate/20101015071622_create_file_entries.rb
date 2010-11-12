class CreateFileEntries < ActiveRecord::Migration
  def self.up
    create_table :file_entries do |t|
      t.integer  :workspace_id
      t.integer  :user_id
      t.string   :title
      t.string   :content_file_name
      t.string   :content_content_type
      t.integer  :content_file_size
      t.datetime :content_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table   :file_entries
  end
end
