class ContactProxy
  module UserMethods
    def followings_contacts
      FollowingsProxy.new(self).xxxs_ids.map{|id|Contact.find_by_id(id)}.compact
    end
    
    def fans_contacts
      FansProxy.new(self).xxxs_ids.map{|id|Contact.find_by_id(id)}.compact
    end
    
    def followings
      followings_contacts.map{|c|c.follow_user}.compact
    end
    
    def fans
      fans_contacts.map{|contact|contact.user}.compact
    end
    
    def following?(user)
      followings.include?(user)
    end

    # 当前用户的联系人包括自己
    def followings_and_self
      followings + [self]
    end

  end

  module ContactMethods
    def self.included(base)
      base.after_create :change_contact_cache_on_create
      base.before_destroy :change_contact_cache_on_destroy
    end

    def change_contact_cache_on_create
      FansProxy.new(self.follow_user).add_to_cache(self.id)
      FollowingsProxy.new(self.user).add_to_cache(self.id)
      return true
    end

    def change_contact_cache_on_destroy
      FansProxy.new(self.follow_user).remove_from_cache(self.id)
      FollowingsProxy.new(self.user).add_to_cache(self.id)
      return true
    end

  end
end
