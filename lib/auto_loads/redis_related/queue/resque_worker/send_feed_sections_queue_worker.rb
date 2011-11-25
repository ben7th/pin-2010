class SendFeedSectionsQueueWorker
  
  @queue = :send_feed_sections_resque_queue

  def self.async_send_tsina_status(options)
    Resque.enqueue(SendFeedSectionsQueueWorker,options)
  end

  def self.perform(options)
    return true if options == "wake_up"
    feed = Feed.find_by_id(options["feed_id"])
    user = User.find_by_id(options["user_id"])
    sections = feed.weibo_sections
    url = self.feed_url(feed)
    first_message_id = 0
    sections.each_with_index do |section,index|
      if index == 0
        if feed.photos.blank?
          id = user.send_message_to_tsina_weibo(section+url)
          first_message_id = id
        else
          path = feed.photos.first.path
          id = user.send_tsina_image_status(path,section+url)
          first_message_id = id
        end
      else
        user.repost_message_to_tsina_weibo(first_message_id,section+url)
      end

      sleep 5*60
    end

  end

  def self.feed_url(feed)
    pin_url_for("pin-user-auth","/feeds/#{feed.id}")
  end
end

