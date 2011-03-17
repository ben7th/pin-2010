class RedisBaseProxy

#两个对外公开接口
public
  # 读缓存，缓存不存在则读数据库
  def xxxs_ids
    re = xxxs_ids_rediscache
    re = xxxs_ids_rediscache_reload if re.nil?
    return re
  end

  # 强制读数据库
  def xxxs_ids_db
    # 使用rails activerecord读数据库
    # 由子类实现
    raise('接口方法 xxxs_ids_db 未实现')
  end

  # 向向量缓存里添加id
  def add_to_cache(id)
    ids = xxxs_ids
    ids.unshift(id).uniq!
    xxxs_ids_rediscache_save(ids)
  end

  def remove_from_cache(id)
    ids = xxxs_ids
    ids.delete(id)
    xxxs_ids_rediscache_save(ids)
  end

private
  # 强制读缓存
  def xxxs_ids_rediscache
    # 读缓存，缓存不存在返回nil，缓存存在但是没有内容返回 []
    # 由子类实现
    raise('cache key 未定义') if @key.nil?
    ids = RedisVectorArrayCache.new(@key).get
    return ids
  end

  def xxxs_ids_rediscache_save(ids)
    # 将ID数组存入向量缓存
    raise('cache key 未定义') if @key.nil?
    RedisVectorArrayCache.new(@key).set(ids)
  end

  # 先读数据库然后更新缓存
  def xxxs_ids_rediscache_reload
    ids = xxxs_ids_db
    xxxs_ids_rediscache_save(ids) #读数据库并写入缓存
    return ids
  end

end
