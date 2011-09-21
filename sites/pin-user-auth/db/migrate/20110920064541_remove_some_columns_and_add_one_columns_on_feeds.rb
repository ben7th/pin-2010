class RemoveSomeColumnsAndAddOneColumnsOnFeeds < ActiveRecord::Migration
  def self.up
    remove_column :feeds,:event
    remove_column :feeds,:quote_of
    remove_column :feeds,:from_viewpoint
    remove_column :feeds,:send_status

    add_column :feeds, :from, :string
  end

  def self.down
  end
end
