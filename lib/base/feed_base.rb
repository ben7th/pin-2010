class FeedBase < UserAuthAbstract
  set_readonly true
  set_table_name("feeds")

  named_scope :news_feeds_of_user,lambda {|user|
    {:conditions=>"feeds.email = '#{user.email}' or feeds.email = '#{EmailActor.get_mindpin_email(user)}'"}
  }

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :feeds do |t|
      t.string :email
      t.string :event
      t.text :detail
      t.timestamps
    end
  end
end