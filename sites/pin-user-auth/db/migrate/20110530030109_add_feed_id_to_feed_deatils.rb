class AddFeedIdToFeedDeatils < ActiveRecord::Migration
  def self.up
    add_column(:feed_details, :feed_id, :integer)
  end

  def self.down
  end
end
