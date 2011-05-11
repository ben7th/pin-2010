=begin
      key user_xx_add_viewpint_tip
      value {
              "#{randstr}"=>{"feed_id"=>"","viewpointer_ids"=>"1,2",:kind=>"add","time"=>""},
              "#{randstr}"=>{"feed_id"=>"","viewpointer_ids"=>"",:kind=>"edit","time"=>""}
            }
=end
class UserAddViewpointTipProxy < BaseTipProxy
  definition_tip_attrs :id,:feed,:viewpointers,:kind,:time
  ADD = "add"
  EDIT = "edit"
  
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_add_viewpint_tip"
    @rh = RedisHash.new(@key)
  end

  def tips
    tips = []
    @rh.all.each do |tip_id,tip_hash|
      feed = Feed.find_by_id(tip_hash["feed_id"])
      viewpointers = tip_hash["viewpointer_ids"].to_s.split(",").uniq.map do |id|
        User.find_by_id(id)
      end.compact
      time = Time.at(tip_hash["time"].to_f)
      kind = tip_hash["kind"]
      next if feed.blank? || viewpointers.blank?
      tips.push(UserAddViewpointTipProxy::Tip.new(tip_id,feed,viewpointers,kind,time))
    end
    tips
  end

  def add_tip_of_add(viewpointer,feed)
    add_tip(viewpointer,feed,ADD)
  end

  def add_tip_of_edit(viewpointer,feed)
    add_tip(viewpointer,feed,EDIT)
  end

  def add_tip(viewpointer,feed,kind)
    tip_id = find_tip_id_by_feed_id_and_kind(feed.id,kind)
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"feed_id"=>feed.id,"viewpointer_ids"=>viewpointer.id,:kind=>kind,"time"=>Time.now.to_f.to_s}
    else
      tip_hash = @rh.get(tip_id)
      tip_hash["viewpointer_ids"] = tip_hash["viewpointer_ids"].to_s.split(",").push(viewpointer.id).uniq*","
    end
    @rh.set(tip_id,tip_hash)
  end

  def find_tip_id_by_feed_id_and_kind(feed_id,kind)
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash["kind"] == kind && tip_hash["feed_id"].to_s == feed_id.to_s
        return tip_id
      end
    end
    return
  end

  class << self
    def add_tip_of_add(viewpoint)
      feed = viewpoint.todo.feed
      viewpointer = viewpoint.user
      return if viewpointer == feed.creator
      self.new(feed.creator).add_tip_of_add(viewpointer,feed)
    end

    def add_tip_of_edit(viewpoint)
      feed = viewpoint.todo.feed
      viewpointer = viewpoint.user
      return if viewpointer == feed.creator
      self.new(feed.creator).add_tip_of_edit(viewpointer,feed)
    end

    def rules
      {
        :class => TodoUser,
        :after_create => Proc.new{|todo_user|
          unless todo_user.memo.blank?
            UserAddViewpointTipProxy.add_tip_of_add(todo_user)
          end
        },
        :after_update => Proc.new{|todo_user|
          memo_arr = todo_user.changes["memo"]
          next if memo_arr.blank?
          if memo_arr.first.blank?
            UserAddViewpointTipProxy.add_tip_of_add(todo_user)
          else
            UserAddViewpointTipProxy.add_tip_of_edit(todo_user)
          end
        }
      }
    end
  end

end
