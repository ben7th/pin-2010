class RedisHash
  def initialize(key)
    @redis = RedisCache.instance
    @key = key
  end

  def all
    hash = @redis.hgetall(@key)
    _hash = {}
    hash.each do |key,value|
      _hash[key] = ActiveSupport::JSON.decode(value)
    end
    _hash
  end

  def set(key,value)
    @redis.hset(@key,key,value.to_json)
  end

  def get(key)
    value = @redis.hget(@key,key)
    return if value.blank?
    ActiveSupport::JSON.decode(value)
  end

  def remove(key)
    @redis.hdel(@key,key)
  end

  def del
    @redis.del(@key)
  end

  def exists?
    @redis.exists(@key)
  end
end
