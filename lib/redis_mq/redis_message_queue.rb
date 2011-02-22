class RedisMessageQueue
  def initialize(key)
    @redis = RedisCache.instance
    @key = key
  end
  
  def all
    @redis.lrange(@key,0,-1)
  end

  # 保留最后进入队列的 count 个消息,其它的全部丢掉
  def retain_message(count)
    if @redis.llen(@key) > count
      @redis.ltrim(@key,0,count-1)
    end
  end

  # 从队列头弹出一个消息
  def pop
    @redis.rpop(@key)
  end

  # 把 value 放入队列
  def push(value)
    @redis.lpush(@key,value)
  end

  # 删除队列中等于 value 的值
  def remove(value)
    @redis.lrem(@key,0,value)
  end

end
