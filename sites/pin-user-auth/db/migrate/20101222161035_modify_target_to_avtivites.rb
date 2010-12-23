class ModifyTargetToAvtivites < ActiveRecord::Migration
  def self.up
    remove_column(:activities, :location_type)
    remove_column(:activities, :location_id)
    remove_column(:activities, :target_id)
    remove_column(:activities, :target_type)
    add_column :activities,:location,:string
    add_column :activities,:detail,:string
  end

  def self.down
  end
end
