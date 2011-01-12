class CreateApiParams < ActiveRecord::Migration
  def self.up
    create_table :api_params do |t|
      t.boolean :required
      t.string :kind
      t.string :description 
      t.string :key
      t.integer :api_help_id
      t.timestamps
    end
    remove_column(:api_helps, :params)
  end

  def self.down
    drop_table :api_params
  end
end
