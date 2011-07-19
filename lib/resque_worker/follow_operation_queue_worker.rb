class FollowOperationQueueWorker
  @queue = :follow_operation_resque_queue

  FOLLOW_OPERATION = "follow"
  UNFOLLOW_OPERATION = "unfollow"

  def self.async_follow_operate(operate,user,contact_user)
    Resque.enqueue(FollowOperationQueueWorker, operate, user.id, contact_user.id)
  end

  def self.perform(operate,user_id,contact_user_id)
    return true if operate == "wake_up"
    user = User.find_by_id(user_id)
    contact_user = User.find_by_id(contact_user_id)
    case operate
    when FOLLOW_OPERATION
      user.add_contact_user(contact_user)
    when UNFOLLOW_OPERATION
      user.remove_contact_user(contact_user)
    end
  end

end
