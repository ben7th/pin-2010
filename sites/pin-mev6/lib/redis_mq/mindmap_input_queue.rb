class MindmapInputQueue
  def initialize
    @key = "mindmap_input_queue"
    @mq = RedisMessageQueue.new(@key)
  end

  # 放入一个 操作
  def push(value)
    @mq.push(value)
  end

  # 取出一个操作
  def pop
    @mq.pop
  end
end
