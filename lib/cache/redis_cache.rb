class RedisCache
  def self.instance
    @@instance ||= begin
      Redis.new(:thread_safe=>true)
    end
  end

  def self.load_proxy(klass)
    rules = [klass.rules].flatten
    raise("#{klass} cache rules 未定义") if rules.nil?
    rules.each do |r|
      @@rules << r
    end

    funcs = [klass.funcs].flatten
    raise("#{klass} cache funcs 未定义") if rules.nil?
    funcs.each do |f|
      @@funcs << f
    end
  end

  def self.refresh_cache_by_rules(model,callback_type)
    mup_ap 'modify REDIS cache by rules'
    mup_ap model
    mup_ap callback_type

    @@rules.each do |r|
      if (r[:class] == model.class) && !r[callback_type].nil?
        r[callback_type].call(model)
      end
    end
  end

  def self.has_method?(model,method_id)
    !self.get_method(model,method_id).nil?
  end

  def self.get_method(model,method_id)
    @@funcs.each do |f|
      if (f[:class] == model.class) && !f[method_id].nil?
        return f
      end
    end
    return nil
  end

  def self.do_method(model,method_id,*args)
    func = self.get_method(model,method_id)
    func[method_id].call(model,*args)
  end

  @@rules = []
  @@funcs = []
  RedisCache.load_proxy(UserFavFeedsProxy)
  RedisCache.load_proxy(FeedFavUsersProxy)
  # ---------- 每增加一个子proxy就配置在这里
  # 用到闭包，method_missing等一些手段，来减少冗余代码
end