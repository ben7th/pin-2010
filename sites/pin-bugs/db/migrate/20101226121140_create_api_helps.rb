class CreateApiHelps < ActiveRecord::Migration
  def self.up
    create_table :api_helps do |t|
      t.string :title
      t.string :description 
      t.string :url
      t.string :format
      t.string :http_method
      t.boolean :need_signup
      t.text :params
      t.text :example
      t.text :memo
      t.text :result
      t.timestamps
    end
  end

  def self.down
    drop_table :api_helps
  end
end
