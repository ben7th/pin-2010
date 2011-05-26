class SendTsinaStatusQueueWorker
  
  @queue = :send_tsina_status_resque_queue

  def self.async_send_tsina_status(options)
    Resque.enqueue(SendTsinaStatusQueueWorker,options)
  end

  def self.perform(options)
    return true if options == "wake_up"
    user = User.find_by_id(options["user_id"])
    content = options["content"]
    if options["image_path"].blank?
      user.send_message_to_tsina_weibo(content)
    else
      user.send_tsina_image_status(options["image_path"],content)
    end
  end
end

