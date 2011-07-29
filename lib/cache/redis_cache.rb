class RedisCache
  if RAILS_ENV == "test"
    DB_COUNT = 3
  else
    DB_COUNT = 2
  end

  def self.instance
    @@instance ||= begin
      redis = Redis.new(:thread_safe=>true)
      redis.select(DB_COUNT)
      redis
    end
  end

end