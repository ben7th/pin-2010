class FeedOperationQueue

  KEY = "feed_operate_queue"
  CREATE_OPERATION = "create"
  DESTROY_OPERATION = "destroy"
  
  def initialize
    @fqq = RedisHashMessageQueue.new(KEY)
  end

  def add_send_feed_task(operate,creator,event,content)
    @fqq.push({:operate=>operate,:creator_id=>creator.id,:event=>event,:content=>content})
  end

  def add_destroy_feed_task(operate,feed_id)
    @fqq.push({:operate=>operate,:feed_id => feed_id})
  end

  def process_task
    a_task_item = @fqq.pop
    return false if a_task_item.blank?
    case a_task_item['operate']
    when CREATE_OPERATION
      creator = User.find_by_id(a_task_item['creator_id'])
      feed = Feed.create(:creator=>creator,:event=>a_task_item['event'],:content=>a_task_item['content'])
      if !!feed
        creator.news_feed_proxy.update_feed(feed)
      end
    when DESTROY_OPERATION
      feed_destroy = Feed.find_by_id(a_task_item['feed_id'])
      feed_destroy.destroy
      # 把关注我的那些人中的这条feed删除
      FeedDestroyProxy.new(feed_destroy).do_operations_after_destroy_feed
    end
    return true
  end
  
end
