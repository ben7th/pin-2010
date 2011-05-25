class AddHideStartupAndLastFeatureUpdateIdToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences,:hide_startup,:boolean
    add_column :preferences,:last_feature_update_id,:integer
  end

  def self.down
  end
end
