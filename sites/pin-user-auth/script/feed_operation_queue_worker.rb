fqq = FeedOperationQueue.new

loop do
  begin
    execute = fqq.process_task
    if !execute
      sleep(1)
    end
  rescue Errno::ECONNREFUSED => ex
    raise "连接 redis 服务出错，feed_operation_queue_worker 关闭"
  rescue Exception => ex
    p "feed_operation_queue_worker 处理输入队列出现异常"
    p ex.message
    puts ex.backtrace*"\n"
  end
end

