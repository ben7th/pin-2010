class SendTsinaStatusQueue
  
  KEY = "send_tsina_status_queue"

  def initialize
    @stsq = RedisHashMessageQueue.new(KEY)
  end

  def add_task(options)
    @stsq.push(options)
    return true
  end

  def process_task
    task_hash = @stsq.pop
    return false if task_hash.blank?
    user = User.find_by_id(task_hash["user_id"])
    content = task_hash["content"]
    if task_hash["image_path"].blank?
      user.send_message_to_tsina_weibo(content)
    else
      user.send_tsina_image_status(task_hash["image_path"],content)
    end
  end
  
end
