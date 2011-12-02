class DeleteTablesAndModifyPosts < ActiveRecord::Migration
  def self.up
    drop_table :feed_comments
    drop_table :feed_details
    drop_table :feed_drafts
    drop_table :feed_mindmaps

    change_column :posts, :detail, :text, :null =>false, :default =>''
    change_column :posts, :title,  :text, :null =>false, :default =>''
  end

  def self.down
  end
end
