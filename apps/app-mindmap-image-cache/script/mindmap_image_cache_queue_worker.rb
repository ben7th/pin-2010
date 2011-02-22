loop do
  begin
    execute = MindmapImageCacheRedisQueue.update_first_item_cache_image
    if !execute
      sleep(1)
    end
  rescue Exception => ex
    p "===============处理缩略图 消息队列时 出现异常==============="
    puts ex.message
    puts ex.backtrace*"\n"
  end

end