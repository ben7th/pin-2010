class RedisCacheSortedSet
  PLACEHOLDER = "PLACEHOLDER_NULL_31415926"
  def initialize(key)
    @redis_cache = RedisCache.instance
    @key = key
  end

  def del
    @redis_cache.del(@key)
  end

  def get_score(member)
    @redis_cache.zscore(@key, member).to_i
  end

  def set_score(member,score)
    @redis_cache.zadd(@key, score, member)
  end

  def increase(member)
    score = get_score(member)+1
    set_score(member,score)
  end

  def decrease(member)
    score = get_score(member)-1
    if score <= 0
      remove(member)
    else
      set_score(member,score)
    end
  end

  def remove(member)
    @redis_cache.zrem(@key, member)
  end

  def member_lists(count = -1)
    if count == -1
      mlist = @redis_cache.zrevrangebyscore(@key, "+inf","-inf")
    else
      mlist = @redis_cache.zrevrangebyscore(@key, "+inf","-inf",:limit=>[0,count])
    end
    mlist-[PLACEHOLDER]
  end

  def lists(count = -1)
    mlist = member_lists(count)
    mlist.map do |m|
      {m=>get_score(m)}
    end
  end

  def exists?
    @redis_cache.exists(@key)
  end

  def touch
    set_score(PLACEHOLDER,0)
  end

end
