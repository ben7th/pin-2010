class AddUsageToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :usage, :string
  end

  def self.down
  end
end
