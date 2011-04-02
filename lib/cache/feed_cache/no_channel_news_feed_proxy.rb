class NoChannelNewsFeedProxy
  def initialize(user)
    @user = user
    vector_cache_key = "feed_vector_no_channel_#{@user.id}"
    @vector_cache = RedisVectorArrayCache.new(vector_cache_key)
  end

  def feeds(paginate_option={})
    id_list = feed_id_list
     if paginate_option.blank?
      first = 0
      count = id_list.count
    else
      first = paginate_option[:per_page]*(paginate_option[:page]-1)
      count = paginate_option[:per_page]
    end
    _feeds = []
    id_list[first..-1].each do |id|
      feed = Feed.find_by_id(id) # 这里已经被 cache-money 缓存了
      if feed.nil?
        remove_feed_id_from_vector_cache(id)
      else
        _feeds.push(feed)
      end
      break if _feeds.count >= count
    end
    _feeds
  end

  def update_feed(feed)
    add_to_vector_cache(feed.id)
  end

  def feed_id_list
    feed_id_list = @vector_cache.get
    if feed_id_list.nil?
      syn_vector_cache
      return @vector_cache.get
    else
      return feed_id_list
    end
  end

  def set_vector_cache(feed_id_list)
    @vector_cache.set(feed_id_list[0..199])
  end

  def remove_feed_id_from_vector_cache(feed_id)
    feed_id_list = @vector_cache.get
    if !feed_id_list.blank?
      @vector_cache.remove(feed_id)
    end
  end

  private
  def add_to_vector_cache(feed_id)
    feed_id_list = @vector_cache.get
    if feed_id_list.nil?
      syn_vector_cache
    else
      feed_id_list.unshift(feed_id)
      set_vector_cache(feed_id_list)
    end
  end

  def syn_vector_cache
    feed_id_list = feed_id_list_from_followings_and_self
    set_vector_cache(feed_id_list)
  end

  def feed_id_list_from_followings_and_self
    feed_id_list = @user.followings_and_self.map do |user|
      # 一个人发送的 没有指定频道的 feed
      user.send_feeds_of_no_channel_db
    end.flatten.map{|feed|feed.id}
    return feed_id_list.sort{|x,y| y<=>x}
  end

  module UserMethods
    def no_channel_feeds(paginate_option={})
      NoChannelNewsFeedProxy.new(self).feeds(paginate_option)
    end
  end
  
end
