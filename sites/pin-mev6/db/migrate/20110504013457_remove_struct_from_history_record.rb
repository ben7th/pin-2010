class RemoveStructFromHistoryRecord < ActiveRecord::Migration
  def self.up
    remove_column :history_records,:struct
  end

  def self.down
  end
end
