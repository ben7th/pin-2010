class AddLogoToTeachers < ActiveRecord::Migration
  def self.up
    add_column :teachers, :logo_file_name,    :string
    add_column :teachers, :logo_content_type, :string
    add_column :teachers, :logo_file_size,    :integer
    add_column :teachers, :logo_updated_at,   :datetime
  end

  def self.down
  end
end
