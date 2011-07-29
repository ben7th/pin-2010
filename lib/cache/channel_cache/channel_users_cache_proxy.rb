class ChannelUsersCacheProxy < RedisBaseProxy
  def initialize(channel)
    @channel = channel
    @key = "channel_#{@channel.id}_user_ids"
  end

  def xxxs_ids_db
    @channel.include_users_db.map{|user|user.id}
  end

  def self.rules
    {
      :class=>ChannelContact,
      :after_create=>Proc.new{|channel_contact|
        user = channel_contact.contact.follow_user
        channel = channel_contact.channel
        next if channel.blank? || user.blank?
        ChannelUsersCacheProxy.new(channel).add_to_cache(user.id)
      },
      :after_destroy=>Proc.new{|channel_contact|
        next if channel_contact.contact.blank?

        user = channel_contact.contact.follow_user
        channel = channel_contact.channel
        next if channel.blank? || user.blank?
        ChannelUsersCacheProxy.new(channel).remove_from_cache(user.id)
      }
    }
  end

  def self.funcs
    {
      :class=>Channel,
      :include_users=>Proc.new{|channel|
        ChannelUsersCacheProxy.new(channel).get_models(User)
      },
      :include_users_and_creator=>Proc.new{|channel|
        channel.include_users + [channel.creator]
      },
      :main_users=>Proc.new{|channel|
        channel.include_users_and_creator
      },
      :'is_include_users_or_creator?'=>Proc.new{|channel,user|
        channel.include_users_and_creator.include?(user)
      }
    }
  end

end
