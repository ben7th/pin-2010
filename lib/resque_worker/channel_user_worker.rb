class ChannelUserWorker

  @queue = :channel_user_operate_resque_queue

  ADD_OPERATION = "add"
  REMOVE_OPERATION = "remove"

  def self.async_channel_user_operate(operate,channel_id,user_id)
    Resque.enqueue(ChannelUserWorker, operate, channel_id, user_id)
  end

  def self.perform(operation,channel_id,user_id)
    return true if operation == "wake_up"
    case operation
    when ADD_OPERATION
      _add_user_to_channel(channel_id,user_id)
    when REMOVE_OPERATION
      _remove_user_from_channel(channel_id,user_id)
    end
  end

  private
  
  def self._add_user_to_channel(channel_id,user_id)
    user = User.find_by_id(user_id)
    channel = Channel.find_by_id(channel_id)
    return if user.blank? || channel.blank?
    channel.add_user(user)
  end

  def self._remove_user_from_channel(channel_id,user_id)
    user = User.find_by_id(user_id)
    channel = Channel.find_by_id(channel_id)
    return if user.blank? || channel.blank?
    channel.remove_user(user)
  end

end
