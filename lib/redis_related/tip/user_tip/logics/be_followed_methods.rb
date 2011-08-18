module BeFollowedMethods
  def self.included(base)
    base.add_enable_kinds(UserTipProxy::BE_FOLLOWED)
    base.extend ClassMethods
    base.add_rules({
        :class => ChannelUser,
        :after_create => Proc.new{|channel_user|
          user = channel_user.user
          channel = channel_user.channel

          channels = channel.creator.channels_of_user(user)
          next if (channels-[channel]).count != 0

          UserTipProxy.create_be_followed_tip_on_queue(channel_user)
        },
        :after_destroy => Proc.new{|channel_user|
          user = channel_user.user
          channel = channel_user.channel

          channels = channel.creator.channels_of_user(user)
          next if (channels-[channel]).count != 0

          UserTipProxy.destroy_be_followed_tip(channel_user)
        }
      })
  end

  def create_be_followed_tip(channel_user)
    tip_id = find_tip_id_by_hash({"channel_user_id"=>channel_user.id,"kind"=>UserTipProxy::BE_FOLLOWED})
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"channel_user_id"=>channel_user.id,"kind"=>UserTipProxy::BE_FOLLOWED,"time"=>Time.now.to_f.to_s}
      @rh.set(tip_id,tip_hash)
    end
  end

  def destroy_be_followed_tip(channel_user)
    tip_id = find_tip_id_by_hash({"channel_user_id"=>channel_user.id,"kind"=>UserTipProxy::BE_FOLLOWED})
    remove_tip_by_tip_id(tip_id) unless tip_id.blank?
  end

  module ClassMethods
    def create_be_followed_tip_on_queue(channel_user)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::BE_FOLLOWED,[channel_user.id])
    end

    def create_be_followed_tip(channel_user)
      UserTipProxy.new(channel_user.user).create_be_followed_tip(channel_user)
    end

    def destroy_be_followed_tip(channel_user)
      UserTipProxy.new(channel_user.user).destroy_be_followed_tip(channel_user)
    end
  end
end
