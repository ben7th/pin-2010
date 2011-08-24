class UserMindmapsMajorWordsProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_mindmaps_major_words"
    @cache = RedisVectorArrayCache.new(@key)
  end


  def major_words
    words = @cache.get
    if words.nil?
      words = refresh_cache
    end
    words
  end

  def refresh_cache
    words = Mindmap.major_words_of_user(@user,10)
    @cache.set(words)
    words
  end

  def self.refresh_cache(user)
    self.new(user).refresh_cache
  end

  def self.rules
    {
      :class => Mindmap ,
      :after_create => Proc.new {|mindmap|
        UserMindmapsMajorWordsProxy.refresh_cache(mindmap.user)
      },
      :after_update => Proc.new {|mindmap|
        next if mindmap.changes["content"].blank?
        next if mindmap.user.blank?
        
        UserMindmapsMajorWordsProxy.refresh_cache(mindmap.user)
      },
      :after_destroy => Proc.new{|mindmap|
        UserMindmapsMajorWordsProxy.refresh_cache(mindmap.user)
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :mindmaps_major_words => Proc.new{|user|
        UserMindmapsMajorWordsProxy.new(user).major_words
      }
    }
  end
end
