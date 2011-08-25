class CreateFeedDrafts < ActiveRecord::Migration
  def self.up
    create_table :feed_drafts do |t|
      t.integer :user_id
      t.string :title
      t.text :content
      t.string :text_format
      t.string :draft_token
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_drafts
  end
end
