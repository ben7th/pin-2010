class ChannelUserOperationQueue
  KEY = "channel_user_operation_queue"
  ADD_OPERATION = "add"
  REMOVE_OPERATION = "remove"
  def initialize
    @ccoq = RedisHashMessageQueue.new(KEY)
  end

  # ChannelUserOperationQueue.new.add_task("add",channel_id,user_id)
  # ChannelUserOperationQueue.new.add_task("remove",channel_id,user_id)
  def add_task(operation,channel_id,user_id)
    raise "不支持 #{operation} 操作" if ![ADD_OPERATION,REMOVE_OPERATION].include?(operation)
    @ccoq.push({:operation=>operation,:channel_id=>channel_id,:user_id=>user_id})
  end

  def process_task
    task_hash = @ccoq.pop
    return false if task_hash.blank?
    operation = task_hash["operation"]
    channel_id = task_hash["channel_id"]
    user_id = task_hash["user_id"]
    case operation
    when ADD_OPERATION
      _add_user_to_channel(channel_id,user_id)
    when REMOVE_OPERATION
      _remove_user_from_channel(channel_id,user_id)
    end
    return true
  end

  private
  def _add_user_to_channel(channel_id,user_id)
    user = User.find_by_id(user_id)
    channel = Channel.find_by_id(channel_id)
    return if user.blank? || channel.blank?
    channel.add_user(user)
  end

  def _remove_user_from_channel(channel_id,user_id)
    user = User.find_by_id(user_id)
    channel = Channel.find_by_id(channel_id)
    return if user.blank? || channel.blank?
    channel.remove_user(user)
  end

end
