class MoveLocationFromFeedsToPosts < ActiveRecord::Migration
  def self.up
    remove_column :feeds,:location
    add_column :posts,:location,:string
  end

  def self.down
  end
end
