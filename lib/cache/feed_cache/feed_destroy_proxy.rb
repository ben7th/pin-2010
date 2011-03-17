class FeedDestroyProxy
  def initialize(feed)
    @feed = feed
    @feed_id = feed.id
    @feed_creator = feed.creator
    @hotfans = @feed_creator.hotfans
  end

  def do_operations_after_destroy_feed
    channels = @feed.channels_db
    if channels.blank?
      destroy_no_channel_feed
    else
      destroy_channels_feed(channels)
    end
  end

  def destroy_no_channel_feed
    destroy_from_user_outbox(@feed_creator)
    destroy_from_user_inbox(@feed_creator)
    destroy_from_user_no_channel(@feed_creator)
    @hotfans.each do |fan|
      destroy_from_user_inbox(fan)
      destroy_from_user_no_channel(fan)
    end
  end

  def destroy_channels_feed(channels)
    channels.each do |channel|
      destroy_from_user_outbox(@feed_creator)
      destroy_from_user_inbox(@feed_creator)
      destroy_from_channel(channel)
      @hotfans.each do |fan|
        destroy_from_user_inbox(fan)
      end
    end
  end

  def destroy_from_user_outbox(user)
    NewsFeedProxy.new(user).remove_feed_id_from_outbox_vector_cache(@feed.id)
  end

  def destroy_from_user_inbox(user)
    NewsFeedProxy.new(user).remove_feed_id_from_inbox_vector_cache(@feed.id)
  end

  def destroy_from_user_no_channel(user)
    NoChannelNewsFeedProxy.new(user).remove_feed_id_from_vector_cache(@feed.id)
  end

  def destroy_from_channel(channel)
    ChannelNewsFeedProxy.new(channel).remove_feed_id_from_vector_cache(@feed.id)
  end

end
