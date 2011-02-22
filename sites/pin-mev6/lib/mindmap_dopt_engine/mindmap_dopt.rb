# 用于思维导图协同编辑调度的dopt算法实现类
# 服务端可以看成协同编辑中一个不发出指令，
# 而且总是比其他客户端节点先接收到编辑指令的特定节点
class MindmapDopt
  def initialize
    @input_mq = MindmapInputQueue.new # 输入消息队列
    @broadcast_mq # 广播消息队列
  end

  # 处理消息队列，对编辑请求进行持久化
  def deal_message_queue
    req = get_request_from_input_mq
    execute = !req.blank?
    execute_request(req) if execute
    return execute
  end

  private
  # 接收并处理编辑请求，并持久化
  def execute_request(req)
    req_t = dopt(req) # 操作转换后的编辑请求
    apply_request_operation(req_t)
    broadcast(req_t)
  end


  # 从输入消息队列中获取一条编辑请求
  def get_request_from_input_mq
    req_string = @input_mq.pop
    return nil if req_string.blank?
    p "处理编辑请求 #{req_string}"
    MindmapEditRequest.new(req_string)
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
