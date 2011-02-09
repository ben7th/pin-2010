class MindmapOperationProxy
  def initialize(mindmap)
    @mindmap = mindmap
    @mindmap_operation_vector_key = "mindmap_operation_vector_#{@mindmap.id}"
    @redis = RedisCache.instance
  end

  # 获得这个导图最近的 20 条操作
  def operations(current_revision)
    if !@redis.exists(@mindmap_operation_vector_key)
      operations = []
    else
      operations = @redis.lrange(@mindmap_operation_vector_key,0,-1).map{|json|ActiveSupport::JSON.decode(json)}
    end
    operations.select{|operation|operation["new_revision"].to_i > current_revision.to_i}
  end

  # 增加操作到 mindmap_operation_vector_cache
  def add_to_mindmap_operation_vector_cache(data_hash)
    json = data_hash.to_json
    length = @redis.lpush(@mindmap_operation_vector_key,json)
    @redis.ltrim(@mindmap_operation_vector_key,0,19) if length > 20
  end

end
