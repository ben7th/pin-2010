class AddEmailToHistoryRecords < ActiveRecord::Migration
  def self.up
    add_column :history_records, :email, :string
  end

  def self.down
  end
end
