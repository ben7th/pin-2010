class SetDefaultMessagesSetToPreferences < ActiveRecord::Migration
  def self.up
    remove_column :preferences,:messages_set
    add_column :preferences, :messages_set, :string, :default=>"only_contacts"
  end

  def self.down
  end
end
