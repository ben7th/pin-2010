class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :mindmap_id
      t.string :node_id
      t.text :content
      t.integer :version
      t.timestamps
    end
    add_index(:notes, :mindmap_id)
  end
end
