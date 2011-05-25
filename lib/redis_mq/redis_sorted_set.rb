class RedisSortedSet
  PLACEHOLDER = "PLACEHOLDER_NULL_31415926"
  def initialize(key)
    @redis = RedisCache.instance
    @key = key
  end

  def del
    @redis.del(@key)
  end

  def get_score(member)
    @redis.zscore(@key, member).to_i
  end

  def set_score(member,score)
    @redis.zadd(@key, score, member)
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
    @redis.zrem(@key, member)
  end

  def member_lists(count = -1)
    if count == -1
      mlist = @redis.zrevrangebyscore(@key, "+inf","-inf")
    else
      mlist = @redis.zrevrangebyscore(@key, "+inf","-inf",:limit=>[0,count])
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
    @redis.exists(@key)
  end

  def touch
    set_score(PLACEHOLDER,0)
  end

end
