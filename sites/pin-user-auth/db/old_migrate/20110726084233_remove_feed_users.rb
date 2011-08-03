class RemoveFeedUsers < ActiveRecord::Migration
  def self.up
    drop_table :feed_users
  end

  def self.down
  end
end
