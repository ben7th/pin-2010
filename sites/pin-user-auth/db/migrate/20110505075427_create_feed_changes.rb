class CreateFeedChanges < ActiveRecord::Migration
  def self.up
    create_table :feed_changes do |t|
      t.integer :feed_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_changes
  end
end
