imq = ImportMindmapQueue.new
Thread.new do
  #清理 完成队列的 残留数据
  loop do
    begin
      sleep 60
      imq.check_complete_queue_and_hash_info
    rescue Errno::ECONNREFUSED => ex
      raise "连接 redis 服务出错，import_mindmap_clear_complete_queue_worker 关闭"
    rescue Exception => ex
      p "import_mindmap_clear_complete_queue_worker 处理输入队列出现异常"
      p ex.message
      puts ex.backtrace*"\n"
    end
  end
end

# 处理 导图导入队列
loop do
  begin
    execute = imq.process_task
    if !execute
      sleep(1)
    end
  rescue Errno::ECONNREFUSED => ex
    raise "连接 redis 服务出错，import_mindmap_worker 关闭"
  rescue Exception => ex
    p "import_mindmap_worker 处理输入队列出现异常"
    p ex.message
    puts ex.backtrace*"\n"
  end
end


