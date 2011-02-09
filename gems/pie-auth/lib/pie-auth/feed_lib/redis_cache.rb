class RedisCache
  def self.instance
    @@instance ||= begin
      Redis.new(:thread_safe=>true)
    end
  end
end