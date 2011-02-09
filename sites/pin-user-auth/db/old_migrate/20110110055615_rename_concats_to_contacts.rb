class RenameConcatsToContacts < ActiveRecord::Migration
  def self.up
    rename_table(:concats, :contacts)
  end

  def self.down
    rename_table(:contacts,:concats)
  end
end
