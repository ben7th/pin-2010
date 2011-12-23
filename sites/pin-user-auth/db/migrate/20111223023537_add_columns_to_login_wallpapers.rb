class AddColumnsToLoginWallpapers < ActiveRecord::Migration
  def self.up
    add_column :login_wallpapers,:in_cycle_list,:boolean,:default=>false
    add_column :login_wallpapers,:user_id,:integer
  end

  def self.down
  end
end
