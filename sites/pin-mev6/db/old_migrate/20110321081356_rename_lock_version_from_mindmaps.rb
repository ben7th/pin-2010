class RenameLockVersionFromMindmaps < ActiveRecord::Migration
  def self.up
    rename_column(:mindmaps,:lock_version,:modified_times)
  end

  def self.down
  end
end
