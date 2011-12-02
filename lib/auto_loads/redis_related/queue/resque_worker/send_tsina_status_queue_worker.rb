class SendTsinaStatusQueueWorker
  
  @queue = :send_tsina_status_resque_queue

  def self.async_send_tsina_status(options)
    Resque.enqueue(SendTsinaStatusQueueWorker,options)
  end

  def self.perform(options)
    return true if options == "wake_up"
    user = User.find_by_id(options["user_id"])
    content = options["content"]
    if !options["image_path"].blank?

      id = user.send_tsina_image_status(options["image_path"],content)
      if id.blank?
        user.send_tsina_image_status_in_queue(options["image_path"],content)
      end

    elsif !options["photo_id"].blank?

      id = user.send_photo_to_tsina_weibo(options["photo_id"],content)
      if id.blank?
        user.send_photo_to_tsina_in_queue(options["photo_id"],content)
      end

    else

      id = user.send_message_to_tsina_weibo(content)
      if id.blank?
        user.send_message_to_tsina_weibo_in_queue(content)
      end

    end
  end
end

