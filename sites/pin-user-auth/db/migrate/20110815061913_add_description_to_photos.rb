class AddDescriptionToPhotos < ActiveRecord::Migration
  def self.up
    add_column(:photos, :description, :text)
  end

  def self.down
  end
end
