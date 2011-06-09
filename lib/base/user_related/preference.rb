class Preference < UserAuthAbstract
  
  ALL_USERS = "all_users"
  ONLY_CONTACTS = "only_contacts"

  class Usage
    FEED = "FEED"
    MINDMAP = "MINDMAP"

    VALUES = [FEED,MINDMAP]
  end

  def self.feed_users_count
    Preference.count(:all,:conditions=>"preferences.usage = '#{Usage::FEED}'")
  end

  def self.mindmap_users_count
    Preference.count(:all,:conditions=>"preferences.usage = '#{Usage::MINDMAP}'")
  end

  index :user_id

  module UserMethods
    def can_send_message_to?(user)
      return true if user.preference.messages_set == ALL_USERS
      user.following?(self)
    end
    
    def hide_startup?
      self.preference.hide_startup?
    end

    def do_hide_startup
      return if self.hide_startup?
      self.preference.update_attributes(:hide_startup=>true)
    end

    def unread_new_feature_tips_count
      id = self.preference.last_feature_update_id
      return 1 if id.blank?
      nids = Tag.system_feature_ids.select{|fid|fid>id}
      nids.count
    end

    def hide_new_feature_tips
      nid = Tag.system_feature_ids.max
      unless nid.blank?
        self.preference.update_attributes(:last_feature_update_id=>nid)
      end
    end

    def unread_new_featrue
      nid = Tag.system_feature_ids.max
      unless nid.blank?
        Feed.find_by_id(nid)
      end
    end

    def unset_usage?
      self.preference.usage.blank?
    end

    def set_usage(usage)
      raise "#{usage} 不是有效的 usage" unless Preference::Usage::VALUES.include?(usage)
      self.preference.update_attributes(:usage=>usage)
    end

    def use_feed?
      self.preference.usage == Preference::Usage::FEED
    end

    def use_mindmap?
      self.preference.usage == Preference::Usage::MINDMAP
    end
    
  end

end