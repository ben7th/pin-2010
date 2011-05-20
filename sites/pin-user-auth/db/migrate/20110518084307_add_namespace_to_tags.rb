class AddNamespaceToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :namespace, :string
  end

  def self.down
  end
end
