class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :content
      t.string :day  # 时间戳比如 20120111 当为空时表示 will todo
      t.integer :position
      t.integer :user_id
      t.timestamps
    end
  end
end
