class AddActiveToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections,:active,:boolean,:default=>true
  end

  def self.down
  end
end
