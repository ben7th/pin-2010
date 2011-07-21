class AddStructHistoryRecords < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE history_records")

    add_column :history_records, :struct, :text
  end

  def self.down
  end
end
