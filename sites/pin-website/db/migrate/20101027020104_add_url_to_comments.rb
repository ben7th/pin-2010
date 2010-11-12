class AddUrlToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :url, :text
    remove_column :comments, :markable_id
    remove_column :comments, :markable_type
  end

  def self.down
  end
end
