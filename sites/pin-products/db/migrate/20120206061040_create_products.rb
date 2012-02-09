class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :code
      t.string :description
      t.text :server_develop_description
      t.text :web_ui_develop_description
      t.text :mobile_client_develop_description
      t.text :deploy_description
      t.text :difficulty
      t.timestamps
    end
  end
end
