class RedisQueueHash
  def initialize(key)
    @redis_queue = RedisQueue.instance
    @key = key
  end

  def all
    hash = @redis_queue.hgetall(@key)
    _hash = {}
    hash.each do |key,value|
      _hash[key] = ActiveSupport::JSON.decode(value)
    end
    _hash
  end

  def set(key,value)
    @redis_queue.hset(@key,key,value.to_json)
  end

  def get(key)
    value = @redis_queue.hget(@key,key)
    return if value.blank?
    ActiveSupport::JSON.decode(value)
  end

  def remove(key)
    @redis_queue.hdel(@key,key)
  end

  def del
    @redis_queue.del(@key)
  end

  def exists?
    @redis_queue.exists(@key)
  end

end
