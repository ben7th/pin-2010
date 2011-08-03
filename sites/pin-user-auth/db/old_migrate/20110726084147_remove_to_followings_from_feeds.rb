class RemoveToFollowingsFromFeeds < ActiveRecord::Migration
  def self.up
    remove_column(:feeds, :to_followings)
  end

  def self.down
  end
end
