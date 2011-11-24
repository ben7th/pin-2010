class DeleteOldTables < ActiveRecord::Migration
  def self.up
    drop_table :html_documents
    drop_table :installings
    # drop_table :invitations
    drop_table :listenings
    drop_table :members
    drop_table :organizations
    drop_table :todos
  end

  def self.down
  end
end
