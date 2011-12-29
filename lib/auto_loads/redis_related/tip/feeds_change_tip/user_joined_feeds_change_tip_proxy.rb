class UserJoinedFeedsChangeTipProxy
  def initialize(user)
    @key = "user_#{user.id}_joined_feeds_change_tip"
    @vector_array = RedisTipVectorArray.new(@key)
  end

  def feed_ids
    @vector_array.get||[]
  end

  def add_feed_id(feed_id)
    ids = feed_ids
    ids.unshift(feed_id).uniq!
    @vector_array.set(ids)
  end

  def remove_feed_id(feed_id)
    ids = feed_ids
    ids.delete(feed_id)
    @vector_array.set(ids)
  end

  def self.add_change_tip(feed_id,users)
    users.each do |user|
      self.new(user).add_feed_id(feed_id)
    end
  end

  def self.rules
    [
      {
        :class => Post,
        :after_create => Proc.new{|post|
          feed = post.feed
          users = feed.joined_users_and_creator
          users = users-[post.user]
          next if users.blank?
          user_ids = users.map{|user|user.id}

          UserJoinedFeedsChangeTipResqueQueueWorker.async_tip(feed.id,user_ids)
        },
        :after_update => Proc.new{|post|
          feed = post.feed
          users = feed.joined_users_and_creator
          users = users-[post.user]
          next if users.blank?
          user_ids = users.map{|user|user.id}

          UserJoinedFeedsChangeTipResqueQueueWorker.async_tip(feed.id,user_ids)
        }
      },
      {
        :class => Feed,
        :after_save => Proc.new{|feed|
          users = feed.joined_users_and_creator
          users = users-[feed.creator]
          next if users.blank?
          user_ids = users.map{|user|user.id}

          UserJoinedFeedsChangeTipResqueQueueWorker.async_tip(feed.id,user_ids)
        }
      }
    ]
  end

  def self.funcs
    {
      :class => User,
      :joined_feeds_change_ids=>Proc.new{|user|
        UserJoinedFeedsChangeTipProxy.new(user).feed_ids
      },
      :remove_from_joined_feeds_change_ids=>Proc.new{|user,feed_id|
        UserJoinedFeedsChangeTipProxy.new(user).remove_feed_id(feed_id)
      }
    }
  end
end
