class AddTitleToBrowseHistoriesAddLogoToWebSites < ActiveRecord::Migration
  def self.up
    add_column :browse_histories, :title, :string
    
    add_column :web_sites,:logo_file_name,:string
    add_column :web_sites,:logo_content_type,:string
    add_column :web_sites,:logo_file_size,:integer
    add_column :web_sites,:logo_updated_at,:datetime
  end

  def self.down
  end
end
