#清理 完成队列的 残留数据
loop do
  begin
    sleep 300
    Resque.enqueue(ChannelUserWorker, "wake_up", "", "")
    Resque.enqueue(FeedOperationQueueWorker, "wake_up", "")
    Resque.enqueue(MindmapImageCacheQueueWorker, "wake_up", "")
    Resque.enqueue(SendTsinaStatusQueueWorker,"wake_up")
  rescue Errno::ECONNREFUSED => ex
    puts ex.backtrace*"\n"
  rescue Exception => ex
    p "唤醒resque worker时出现异常"
    p ex.message
    puts ex.backtrace*"\n"
  end
end