class FollowOperationQueue
  KEY = "follow_operation_queue"
  FOLLOW_OPERATION = "follow"
  UNFOLLOW_OPERATION = "unfollow"
  def initialize
    @foq = RedisHashMessageQueue.new(KEY)
  end

  def add_follow_task(user,contact_user)
    @foq.push({:operation=>FOLLOW_OPERATION,:user_id=>user.id,:contact_user_id=>contact_user.id})
    return true
  end

  def add_unfollow_task(user,contact_user)
    @foq.push({:operation=>UNFOLLOW_OPERATION,:user_id=>user.id,:contact_user_id=>contact_user.id})
    return true
  end

  def process_task
    task_hash = @foq.pop
    return false if task_hash.blank?
    operation = task_hash["operation"]
    user = User.find_by_id(task_hash["user_id"])
    contact_user = User.find_by_id(task_hash["contact_user_id"])
    case operation
    when FOLLOW_OPERATION
      user.add_contact_user(contact_user)
    when UNFOLLOW_OPERATION
      contact = user.get_contact_obj_of(contact_user)
      contact.destroy if !!contact
    end
    return true
  end

end
