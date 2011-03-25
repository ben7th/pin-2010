class CreateFeedComments < ActiveRecord::Migration
  def self.up
    create_table :feed_comments do |t|
      t.integer :feed_id
      t.integer :user_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_comments
  end
end
