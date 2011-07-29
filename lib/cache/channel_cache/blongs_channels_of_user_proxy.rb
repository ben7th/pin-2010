class BlongsChannelsOfUserProxy < RedisBaseProxy
  def initialize(user,channel_owner)
    @user = user
    @channel_owner = channel_owner
    @key = "user_#{@user.id}_channel_of_user_#{channel_owner.id}_ids"
  end

  def xxxs_ids_db
    @channel_owner.channels_of_user_db(@user).map {|channel| channel.id }
  end

  def self.rules
    {
      :class=>ChannelContact,
      :after_create=>Proc.new{|channel_contact|
        user = channel_contact.contact.follow_user
        channel = channel_contact.channel
        next if channel.blank? || user.blank?
        BlongsChannelsOfUserProxy.new(user,channel.creator).add_to_cache(channel.id)
      },
      :after_destroy=>Proc.new{|channel_contact|
        next if channel_contact.contact.blank?

        user = channel_contact.contact.follow_user
        channel = channel_contact.channel
        next if channel.blank? || user.blank?
        BlongsChannelsOfUserProxy.new(user,channel.creator).remove_from_cache(channel.id)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :channels_of_user=>Proc.new{|channels_owner,user|
        BlongsChannelsOfUserProxy.new(user,channels_owner).get_models(Channel)
      }
    }
  end

end
