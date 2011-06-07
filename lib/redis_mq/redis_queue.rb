class RedisQueue
  def self.instance
    @@instance ||= begin
      redis = Redis.new(:thread_safe=>true)
      redis
    end
  end
end
