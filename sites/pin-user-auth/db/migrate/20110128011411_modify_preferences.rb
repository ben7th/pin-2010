class ModifyPreferences < ActiveRecord::Migration
  def self.up
    remove_column :preferences,:theme
    remove_column :preferences,:show_tooltip
    remove_column :preferences,:updated_at
    remove_column :preferences,:created_at
    remove_column :preferences,:auto_popup_msg

    add_column :preferences, :messages_set, :string
  end

  def self.down
  end
end
