class AddVoteScoreToTodoUsers < ActiveRecord::Migration
  def self.up
    add_column :todo_users, :vote_score, :integer,:default => 0
  end

  def self.down
    remove_column :todo_users, :vote_score
  end
end
