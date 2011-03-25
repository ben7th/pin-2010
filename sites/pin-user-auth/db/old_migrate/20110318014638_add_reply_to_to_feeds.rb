class AddReplyToToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds,:reply_to,:integer
  end

  def self.down
  end
end
