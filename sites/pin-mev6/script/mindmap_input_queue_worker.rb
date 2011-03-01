md = MindmapDopt.new

while true
  begin
    execute = md.deal_message_queue
    if !execute
      sleep(1)
    end
  rescue Errno::ECONNREFUSED => ex
    raise "连接 redis 服务出错，mindpin_input_mq 关闭"
  rescue Mysql::Error => ex
#    ActiveRecord::Base.verify_active_connections!
    p ex.message
    raise "数据库工作异常，worker 关闭"
  rescue Exception => ex
    p "处理输入队列出现异常"
    p ex.message
    puts ex.backtrace*"\n"
  end
end