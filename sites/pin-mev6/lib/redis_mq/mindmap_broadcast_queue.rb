class MindmapBroadcastQueue
  def initialize(mindmap)
    @mindmap = mindmap
    @key = "mindmap_#{mindmap.id}_broadcast_queue"
    @mq = RedisMessageQueue.new(@key)
  end

  def pop
    @mq.pop
  end

  def push(value)
    @mq.push(value)
    @mq.retain_message(100)
  end

  def all
    @mq.all.reverse
  end

  def get_by_conditions(user,req_rev_local,req_rev_remote)
    p req_rev_remote
    opers = all.map {|m|ActiveSupport::JSON.decode(m)}
    p opers
    # 不是自己的
    opers.select  do |oper|
      queue_new_rev_remote = oper["new_rev_remote"].to_i
      oper["user"] != user.email &&
        req_rev_remote.to_i < queue_new_rev_remote
#        pull_req_rev_remote < queue_new_rev_remote
#        req_rev_local.to_i <= queue_rev_remote && queue_rev_remote <= req_rev_remote.to_i
    end
  end

end
