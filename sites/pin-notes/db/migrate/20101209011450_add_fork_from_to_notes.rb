class AddForkFromToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes,:fork_from_data,:string
  end

  def self.down
    remove_column :notes,:fork_from_data
  end
end
