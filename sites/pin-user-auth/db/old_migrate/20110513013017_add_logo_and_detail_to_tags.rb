class AddLogoAndDetailToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :logo_file_name,    :string
    add_column :tags, :logo_content_type, :string
    add_column :tags, :logo_file_size,    :integer
    add_column :tags, :logo_updated_at,   :datetime
    add_column :tags, :detail,            :text
  end

  def self.down
    remove_column :tags, :logo_file_name
    remove_column :tags, :logo_content_type
    remove_column :tags, :logo_file_size
    remove_column :tags, :logo_updated_at
    remove_column :tags, :detail
  end
end
