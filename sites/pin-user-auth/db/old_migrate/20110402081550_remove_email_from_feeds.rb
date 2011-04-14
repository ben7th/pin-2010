class RemoveEmailFromFeeds < ActiveRecord::Migration
  def self.up
    remove_column :feeds,:email
  end

  def self.down
  end
end
