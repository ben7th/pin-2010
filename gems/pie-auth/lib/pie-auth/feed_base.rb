class FeedBase < ActiveRecord::Base
  set_readonly true
  build_database_connection(CoreService::USER_AUTH,{:table_name=>"feeds"})

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

    # 当前用户的联系人包括自己
    def following_users
      cap = ContactAttentionProxy.new(self)
      cts = cap.followings_contacts
      cts.map{|c|EmailActor.get_user_by_email(c.email)}.compact + [self]
    end

    def fans_contacts
      cap = ContactAttentionProxy.new(self)
      cap.fans_contacts
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