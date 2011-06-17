class CreateReputationLogs < ActiveRecord::Migration
  def self.up
    create_table :reputation_logs do |t|
      t.integer :user_id
      t.string :kind
      t.text :info_json
      t.timestamps
    end
  end

  def self.down
    drop_table :reputation_logs
  end
end
