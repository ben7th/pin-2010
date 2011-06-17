class RedisCache
  def self.instance
    @@instance ||= begin
      redis = Redis.new(:thread_safe=>true)
      redis.select(2)
      redis
    end
  end

end