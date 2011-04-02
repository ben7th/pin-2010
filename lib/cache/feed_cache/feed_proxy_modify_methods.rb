=begin
  1 增加一个联系人 a
    add a.outbox to self.inbox
    add a.feeds_of_no_channel to self.no_channel
  2 删除一个联系人 a
    remove a.outbox from self.inbox
    remove a.feeds_of_no_channel from self.no_channel
=end
module FeedProxyModifyMethods
  # NewsFeedProxy.new(user).add_contact_user(contact_user)
  def add_contact_user(contact_user)
    add_user_outbox_to_self_inbox(contact_user)
    add_user_feeds_of_no_channel_to_self_no_channel(contact_user)
  end

  def remove_contact_user(contact_user)
    remove_user_outbox_from_self_inbox(contact_user)
    remove_user_feeds_of_no_channel_from_self_no_channel(contact_user)
  end

  # 增加 user 的 发件箱中的 feed 到 当前用户收件箱中
  def add_user_outbox_to_self_inbox(user)
    _outbox_id_list = user.news_feed_proxy.outbox_id_list
    _inbox_id_list = inbox_id_list
    all_id_list = (_outbox_id_list + _inbox_id_list).uniq
    all_id_list.sort!{|x,y| y<=>x}
    re = all_id_list[0..199]
    # 设置 inbox 缓存
    set_inbox_vector_cache(re)
  end

  # 增加 user 的 未指定channle的 feed 到 当前用户收件箱中 feed
  def add_user_feeds_of_no_channel_to_self_no_channel(user)
    no_channel_news_feed_proxy = NoChannelNewsFeedProxy.new(@user)
    no_channel_id_list = no_channel_news_feed_proxy.feed_id_list
    add_id_list = user.send_feeds_of_no_channel_db.map{|feed|feed.id}
    all_id_list = (add_id_list + no_channel_id_list).uniq
    all_id_list.sort!{|x,y| y<=>x}
    no_channel_news_feed_proxy.set_vector_cache(all_id_list)
  end

  # 从 当前用户收件箱中 删除 user 的 发件箱中的 feed
  def remove_user_outbox_from_self_inbox(user)
    _outbox_id_list = user.news_feed_proxy.outbox_id_list
    _inbox_id_list = inbox_id_list
    all_id_list = _inbox_id_list - _outbox_id_list
    all_id_list = select_not_user_feed(all_id_list,user)
    all_id_list.sort!{|x,y| y<=>x}
    re = all_id_list[0..199]
    # 设置 inbox 缓存
    set_inbox_vector_cache(re)
  end

    # 从 feed_ids 中 选择不是 user 的
  def select_not_user_feed(feed_ids,user)
    feed_ids.select do |feed_id|
      feed = Feed.find_by_id(feed_id)
      feed && feed.creator !=user
    end
  end

  def remove_user_feeds_of_no_channel_from_self_no_channel(user)
    no_channel_news_feed_proxy = NoChannelNewsFeedProxy.new(@user)
    no_channel_id_list = no_channel_news_feed_proxy.feed_id_list
    remove_id_list = user.send_feeds_of_no_channel_db.map{|feed|feed.id}
    all_id_list = no_channel_id_list - remove_id_list
    all_id_list = select_not_user_feed(all_id_list,user)
    all_id_list.sort!{|x,y| y<=>x}
    no_channel_news_feed_proxy.set_vector_cache(all_id_list)
  end

  module ContactMethods
    def self.included(base)
      base.after_create :change_feed_cache_on_add_contact_user
      base.after_destroy :change_feed_cache_on_remove_contact_user
    end

    def change_feed_cache_on_add_contact_user
      NewsFeedProxy.new(self.user).add_contact_user(self.follow_user)
      return true
    end

    def change_feed_cache_on_remove_contact_user
      NewsFeedProxy.new(self.user).remove_contact_user(self.follow_user)
      return true
    end

  end

end
