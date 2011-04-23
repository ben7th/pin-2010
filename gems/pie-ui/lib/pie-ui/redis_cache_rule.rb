module RedisCacheRule
  def self.included(base)
    base.after_create   :refresh_cache_after_create
    base.after_update   :refresh_cache_after_update
    base.after_destroy  :refresh_cache_after_destroy

    base.alias_method_chain :method_missing, :redis_cache_rule
    base.alias_method_chain :respond_to?, :redis_cache_rule
  end

  def refresh_cache_after_create
    refresh_redis_cache(:after_create)
  end

  def refresh_cache_after_update
    refresh_redis_cache(:after_update)
  end

  def refresh_cache_after_destroy
    refresh_redis_cache(:after_destroy)
  end

  def refresh_redis_cache(callback_type)
    RedisCache.refresh_cache_by_rules(self,callback_type)
    return true
  end

  def respond_to_with_redis_cache_rule?(method_id)
    if respond_to_without_redis_cache_rule?(method_id)
      return true
    else
      return RedisCache.has_method?(self,method_id.to_sym)
    end
  end

  def method_missing_with_redis_cache_rule(method_id, *args)
    if RedisCache.has_method?(self,method_id)
      return RedisCache.do_method(self,method_id, *args)
    else
      return method_missing_without_redis_cache_rule(method_id, *args)
    end
  end
end
