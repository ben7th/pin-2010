class AddToFollowingsToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :to_followings, :boolean,:default =>false
  end

  def self.down
  end
end
