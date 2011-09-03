class RedisTipHash
  # 用于包装通知数据的基础类

  def initialize(key)
    @redis_tip = RedisTip.instance
    @key = key
  end

  # 返回所有hash，进行json decode
  def all
    hash = @redis_tip.hgetall(@key)
    _hash = {}
    hash.each do |hkey,hvalue|
      _hash[hkey] = ActiveSupport::JSON.decode(hvalue)
    end
    _hash
  end

  def set(hkey,hvalue)
    @redis_tip.hset(@key,hkey,hvalue.to_json)
  end

  def get(hkey)
    value = @redis_tip.hget(@key,hkey)
    return nil if value.blank?
    ActiveSupport::JSON.decode(value)
  end

  def remove(hkey)
    @redis_tip.hdel(@key,hkey)
  end

  def del
    @redis_tip.del(@key)
  end

  def exists?
    @redis_tip.exists(@key)
  end

end
