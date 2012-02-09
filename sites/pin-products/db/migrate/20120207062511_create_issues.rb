class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :product_id 
      t.text :content
      t.string :status
      t.timestamps
    end
  end
end
