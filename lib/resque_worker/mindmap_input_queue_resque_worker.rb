class MindmapInputQueueResqueWorker
  
  @queue = :mindmap_input_queue_worker

  def self.async_mindmap_input_queue(req_json)
    Resque.enqueue(MindmapInputQueueResqueWorker, req_json)
  end

  def self.perform(req_json)
    mirw = MindmapInputQueueResqueWorker.new
    req = mirw.get_request_from_input_mq(req_json)
    mirw.execute_request(req)
  end

  # 接收并处理编辑请求，并持久化
  def execute_request(req)
    req_t = dopt(req) # 操作转换后的编辑请求
    apply_request_operation(req_t)
    broadcast(req_t)
  end


  # 从输入消息队列中获取一条编辑请求
  def get_request_from_input_mq(req_json)
    MindmapEditRequest.new(req_json)
  end

  def dopt(req)
    # TODO 具体算法实现
    return req
  end

  # 执行请求，修改持久化数据
  def apply_request_operation(req)
    op      = req.op
    user    = req.user
    mindmap = req.mindmap
    MindmapOperate.new(mindmap,op,user).do_operation
  end

  def broadcast(req)
    req.push_to_mindmap_broadcast_queue
  end

end
