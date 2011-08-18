class UserBeingQuotedFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_being_quoted_feeds"
  end

  def xxxs_ids_db
    feed_ids = Feed.news_feeds_of_user(@user).map{|feed|feed.id}
    Feed.find(:all,:conditions => [ "quote_of IN (?)",feed_ids]).map do |feed|
      feed.id
    end.sort{|x,y| y<=>x}
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        if feed.quote_of
          qf = Feed.find_by_id(feed.quote_of)
          if qf
            UserBeingQuotedFeedsProxy.new(qf.creator).add_to_cache(feed.id)
          end
        end
      },
      :after_destroy => Proc.new {|feed|
        if feed.quote_of
          qf = Feed.find_by_id(feed.quote_of)
          if qf
            UserBeingQuotedFeedsProxy.new(qf.creator).remove_from_cache(feed.id)
          end
        end
      }
    }
  end
  
  def self.funcs
    {
      :class  => User ,
      :being_quoted_feeds => Proc.new {|user|
        UserBeingQuotedFeedsProxy.new(user).get_models(Feed)
      }
    }
  end
end
