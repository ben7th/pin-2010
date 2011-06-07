class RedisTip
  def self.instance
    @@instance ||= begin
      redis = Redis.new(:thread_safe=>true)
      redis.select(1)
      redis
    end
  end
end
