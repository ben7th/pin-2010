class AddHeadCoverToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :head_cover_file_name,    :string
    add_column :preferences, :head_cover_content_type, :string
    add_column :preferences, :head_cover_file_size,    :integer
    add_column :preferences, :head_cover_updated_at,   :datetime
  end

  def self.down
  end
end
