class ChannelNewsFeedProxy
  def initialize(channel)
    @channel = channel
    vector_cache_key = "feed_vector_channel_#{@channel.id}"
    @vector_cache = RedisVectorArrayCache.new(vector_cache_key)
  end

  def feeds(paginate_option={})
    if paginate_option.blank?
      id_list = feed_id_list
    else
      id_list = feed_id_list.paginate(paginate_option)
    end
    id_list.map{|id|Feed.find_by_id(id)}.compact
  end

  def update_feed(feed)
    add_to_vector_cache(feed.id)
  end

  private
  def feed_id_list
    feed_id_list = @vector_cache.get
    if feed_id_list.nil?
      syn_vector_cache
      return @vector_cache.get
    else
      return feed_id_list
    end
  end
  
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
    feed_id_list = feed_id_list_from_channel_users
    set_vector_cache(feed_id_list)
  end

  def feed_id_list_from_channel_users
    feed_id_list = @channel.include_users.map do |user|
      user.news_feed_proxy.outbox_id_list_newer_than(nil)
    end.flatten
    # 排序，大的就是新的，排在前面
    return feed_id_list.sort{|x,y| y<=>x}
  end

  def set_vector_cache(feed_id_list)
    @vector_cache.set(feed_id_list[0..199])
  end

  module ChannelMethods
    def feeds(paginate_option={})
      ChannelNewsFeedProxy.new(self).feeds(paginate_option)
    end
  end
end
