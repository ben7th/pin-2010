class ChangeViewpointsToPosts < ActiveRecord::Migration
  def self.up
    rename_table(:viewpoints,:posts)
  end

  def self.down
  end
end
