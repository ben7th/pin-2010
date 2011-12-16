module ContactCacheModule

  class FollowingsProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{@user.id}_followings_vector"
    end

    def xxxs_ids_db
      @user.followings_db.map{|user|user.id}
    end

    def self.tidy!
      self.base_tidy!(User,User)
    end

    def self.one_tidy!(key_id)
      self.base_one_tidy!(User,User,key_id)
    end
  end

  class FansProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{@user.id}_fans_vector"
    end

    def xxxs_ids_db
      @user.fans_db.map{|user|user.id}
    end

    def self.tidy!
      self.base_tidy!(User,User)
    end

    def self.one_tidy!(key_id)
      self.base_one_tidy!(User,User,key_id)
    end
  end

  class LogicRules
    def self.rules
      {
        :class=>ChannelUser,
        :after_create=>Proc.new{|channel_user|
          user = channel_user.user
          channel = channel_user.channel
          channels = channel.creator.channels_of_user(user)
          next if (channels-[channel]).count != 0
    
          FollowingsProxy.new(channel.creator).add_to_cache(user.id)
          FansProxy.new(user).add_to_cache(channel.creator.id)
        },
        :after_destroy=>Proc.new{|channel_user|
          user = channel_user.user
          channel = channel_user.channel
          channels = channel.creator.channels_of_user(user)
          next if (channels-[channel]).count != 0

          FollowingsProxy.new(channel.creator).remove_from_cache(user.id)
          FansProxy.new(user).remove_from_cache(channel.creator.id)
        }
      }
    end

    def self.funcs
      {
        :class=>User,
        :fans=>Proc.new{|user|
          FansProxy.new(user).get_models(User)
        },
        :fans_and_self=>Proc.new{|user|
          user.fans + [user]
        },
        :followings=>Proc.new{|user|
          FollowingsProxy.new(user).get_models(User)
        },
        :'following?'=>Proc.new{|user,follow_user|
          ids = FollowingsProxy.new(user).xxxs_ids
          ids.include?(follow_user.id)
        },
        :followings_and_self=>Proc.new{|user|
          user.followings + [user]
        },
        :following_user_ids=>Proc.new{|user|
          FollowingsProxy.new(user).xxxs_ids
        },
        :mutual_followings=>Proc.new{|user|
          fans_ids = FansProxy.new(user).xxxs_ids
          followings_ids = FollowingsProxy.new(user).xxxs_ids
          ids = (fans_ids & followings_ids)
          ids.map{|id|User.find_by_id(id)}.compact
        }
      }
    end
  end
end
