class DeleteLogoFromMindmaps < ActiveRecord::Migration
  def self.up
    remove_column :mindmaps, :logo_file_name, :logo_content_type, :logo_file_size, :logo_updated_at
  end

  def self.down
  end
end
