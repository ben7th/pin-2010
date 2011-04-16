ccoq = ChannelUserOperationQueue.new
# 处理 导图导入队列
loop do
  begin
    execute = ccoq.process_task
    if !execute
      sleep(1)
    end
  rescue Errno::ECONNREFUSED => ex
    raise "连接 redis 服务出错，channel_user_operation_queue_worker 关闭"
  rescue Exception => ex
    p "channel_user_operation_queue_worker 处理输入队列出现异常"
    p ex.message
    puts ex.backtrace*"\n"
  end
end


