class ChangeColumnNameOnFeeds < ActiveRecord::Migration
  def self.up
    rename_column(:feeds, :reply_to, :repost_feed_id)
  end

  def self.down
  end
end
