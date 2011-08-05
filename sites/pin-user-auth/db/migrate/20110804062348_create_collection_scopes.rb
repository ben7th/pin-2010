class CreateCollectionScopes < ActiveRecord::Migration
  def self.up
    create_table :collection_scopes do |t|
      t.integer :collection_id
      t.string :param
      t.integer :scope_id
      t.string :scope_type
      t.timestamps
    end
  end

  def self.down
    drop_table :collection_scopes
  end
end
