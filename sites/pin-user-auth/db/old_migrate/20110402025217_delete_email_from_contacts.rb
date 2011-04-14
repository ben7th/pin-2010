class DeleteEmailFromContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts,:email
  end

  def self.down
  end
end
