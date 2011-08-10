class AddCurrentHistoryRecordIdToMindmaps < ActiveRecord::Migration
  def self.up
    add_column :mindmaps, :current_history_record_id, :integer,:default => nil
  end

  def self.down
  end
end
