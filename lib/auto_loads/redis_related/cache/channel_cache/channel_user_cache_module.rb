module ChannelUserCacheModule

  class UserChannelsCacheProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{@user.id}_channel_ids"
    end

    # 缓存初始化查询方法
    def xxxs_ids_db
      @user.belongs_to_channels_db.map{|channel| channel.id}
    end
  end

  class ChannelUsersCacheProxy < RedisBaseProxy
    def initialize(channel)
      @channel = channel
      @key = "channel_#{@channel.id}_user_ids"
    end

    def xxxs_ids_db
      @channel.include_users_db.map{|user| user.id}
    end
  end

  class BelongsChannelsOfUserProxy < RedisBaseProxy
    def initialize(user,channel_owner)
      @user = user
      @channel_owner = channel_owner
      @key = "user_#{@user.id}_channel_of_user_#{channel_owner.id}_ids"
    end

    def xxxs_ids_db
      @channel_owner.channels_of_user_db(@user).map {|channel| channel.id }
    end
  end


  class LogicRules
    def self.rules
      {
        :class=>ChannelUser,
        :after_create=>Proc.new{|channel_user|
          user = channel_user.user
          channel = channel_user.channel
          next if channel.blank? || user.blank?

          UserChannelsCacheProxy.new(user).add_to_cache(channel.id)
          ChannelUsersCacheProxy.new(channel).add_to_cache(user.id)
          BelongsChannelsOfUserProxy.new(user, channel.creator).add_to_cache(channel.id)
        },
        :after_destroy=>Proc.new{|channel_user|
          user = channel_user.user
          channel = channel_user.channel
          next if channel.blank? || user.blank?

          UserChannelsCacheProxy.new(user).remove_from_cache(channel.id)
          ChannelUsersCacheProxy.new(channel).remove_from_cache(user.id)
          BelongsChannelsOfUserProxy.new(user, channel.creator).remove_from_cache(channel.id)
        }
      }
    end

    def self.funcs
      [
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
        },
        {
          :class=>User,
          :belongs_to_channels_count=>Proc.new{|user|
            UserChannelsCacheProxy.new(user).xxxs_ids.count
          },
          :belongs_to_channels=>Proc.new{|user|
            UserChannelsCacheProxy.new(user).get_models(Channel)
          },
          :belongs_to_followings_channels=>Proc.new{|user|
            user.belongs_to_channels.select{|channel|user.following_user_ids.include?(channel.creator_id)}
          },
          :belongs_to_no_followings_channels=>Proc.new{|user|
            user.belongs_to_channels.select{|channel|!user.following_user_ids.include?(channel.creator_id)}
          },
          :channels_of_user=>Proc.new{|channels_owner,user|
            BelongsChannelsOfUserProxy.new(user,channels_owner).get_models(Channel)
          }
        }
      ]
    end

  end

end
