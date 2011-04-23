class CreateTodoMemoComments < ActiveRecord::Migration
  def self.up
    create_table :todo_memo_comments do |t|
      t.integer :todo_user_id
      t.integer :user_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :todo_memo_comments
  end
end
