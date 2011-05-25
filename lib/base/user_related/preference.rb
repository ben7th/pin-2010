class Preference < UserAuthAbstract
  
  ALL_USERS = "all_users"
  ONLY_CONTACTS = "only_contacts"

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
  end

end