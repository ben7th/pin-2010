class FeedOperationQueueWorker

  @queue = :feed_operation_queue_worker

  CREATE_OPERATION = "create"
  DESTROY_OPERATION = "destroy"

  # 创建的时候，参数格式如下
  # operate,{:creator_id => creator.id,:event => event,:content => content}
  # 删除的时候，参数格式如下
  # operate,{:feed_id => feed_id}
  def self.async_feed_operate(operate,options)
    Resque.enqueue(FeedOperationQueueWorker, operate, options)
  end

  def self.perform(operate,options)
    return true if operate == "wake_up"
    case operate
    when CREATE_OPERATION
      creator = User.find_by_id(options['creator_id'])
      feed = Feed.create(:creator=>creator,:event=>options['event'],:content=>options['content'])
    when DESTROY_OPERATION
      feed_destroy = Feed.find_by_id(options['feed_id'])
      feed_destroy.destroy
    end
  end

  
end
