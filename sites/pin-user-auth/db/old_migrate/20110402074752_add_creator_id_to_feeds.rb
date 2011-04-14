class AddCreatorIdToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds,:creator_id,:integer
  end

  def self.down
  end
end
