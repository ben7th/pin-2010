class AddDefaultValueToLastFeatureUpdateIdOnPreferences < ActiveRecord::Migration
  def self.up
    change_column(:preferences, :last_feature_update_id, :integer,:null =>false, :default =>0)
  end

  def self.down
  end
end
