class FeedBase < UserAuthAbstract
  set_readonly true
  set_table_name("feeds")

  named_scope :news_feeds_of_user,lambda {|user|
    {:conditions=>"feeds.email = '#{user.email}' or feeds.email = '#{EmailActor.get_mindpin_email(user)}'"}
  }

  module UserMethods
    def news_feeds
      Feed.news_feeds_of_user(self)
    end

    def news_feed_proxy
      NewsFeedProxy.new(self)
    end

    # 把当前用户作为联系人的在线用户
    # 暂时 忽略 在不在线
    def hotfans
      fans_contacts.map{|c|c.user}.compact
    end

  end

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :feeds do |t|
      t.string :email
      t.string :event
      t.text :detail
      t.timestamps
    end
  end
end