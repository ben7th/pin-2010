class AddFeedIdToViewpoints < ActiveRecord::Migration
  def self.up
    add_column(:viewpoints, :feed_id, :integer)
  end

  def self.down
  end
end
