foq = FollowOperationQueue.new

loop do
  begin
    execute = foq.process_task
    if !execute
      sleep(1)
    end
  rescue Errno::ECONNREFUSED => ex
    raise "连接 redis 服务出错，follow_operation_queue_worker 关闭"
  rescue Exception => ex
    p "follow_operation_queue_worker 处理输入队列出现异常"
    p ex.message
    puts ex.backtrace*"\n"
  end
end


