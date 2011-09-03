class UserTipRedisCache
  # 用于包装通知数据的基础类

  def initialize(cache_key)
    @redis_tip = RedisTip.instance
    @cache_key = cache_key
  end

  def set(hkey, raw_hvalue)
    @redis_tip.hset(@cache_key, hkey, raw_hvalue.to_json)
  end

  def get(hkey)
    encoded_hvalue = @redis_tip.hget(@cache_key, hkey)
    return nil if encoded_hvalue.blank?
    ActiveSupport::JSON.decode(encoded_hvalue)
  end

  def remove(hkey)
    @redis_tip.hdel(@cache_key, hkey)
  end


  # 返回所有hash，进行json decode
  def all
    cache_hash = @redis_tip.hgetall(@cache_key)
    
    _hash = {}
    cache_hash.each do |hkey, encoded_hvalue|
      _hash[hkey] = ActiveSupport::JSON.decode(encoded_hvalue)
    end
    _hash
  end

  def count
    @redis_tip.hgetall(@cache_key).count
  end

  def remove_all
    @redis_tip.del(@cache_key)
  end

  def exists?
    @redis_tip.exists(@cache_key)
  end

end
