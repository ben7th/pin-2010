class RedisTipHash

  def initialize(key)
    @redis_tip = RedisTip.instance
    @key = key
  end

  def all
    hash = @redis_tip.hgetall(@key)
    _hash = {}
    hash.each do |key,value|
      _hash[key] = ActiveSupport::JSON.decode(value)
    end
    _hash
  end

  def set(key,value)
    @redis_tip.hset(@key,key,value.to_json)
  end

  def get(key)
    value = @redis_tip.hget(@key,key)
    return if value.blank?
    ActiveSupport::JSON.decode(value)
  end

  def remove(key)
    @redis_tip.hdel(@key,key)
  end

  def del
    @redis_tip.del(@key)
  end

  def exists?
    @redis_tip.exists(@key)
  end

end
