class AddPrivateIdToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes,:private_id,:string
  end

  def self.down
    remove_column :notes,:private_id
  end
end
