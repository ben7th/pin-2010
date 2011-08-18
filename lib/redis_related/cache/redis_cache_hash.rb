class RedisCacheHash
  def initialize(key)
    @redis_cache = RedisCache.instance
    @key = key
  end

  def all
    hash = @redis_cache.hgetall(@key)
    _hash = {}
    hash.each do |key,value|
      _hash[key] = ActiveSupport::JSON.decode(value)
    end
    _hash
  end

  def set(key,value)
    @redis_cache.hset(@key,key,value.to_json)
  end

  def get(key)
    value = @redis_cache.hget(@key,key)
    return if value.blank?
    ActiveSupport::JSON.decode(value)
  end

  def remove(key)
    @redis_cache.hdel(@key,key)
  end

  def del
    @redis_cache.del(@key)
  end

  def exists?
    @redis_cache.exists(@key)
  end
end




  


