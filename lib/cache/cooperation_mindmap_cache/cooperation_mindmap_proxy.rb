module CooperationMindmapProxy
  module UserMethods
    def cooperate_mindmaps
      UserCooperateMindmapsProxy.new(self).xxxs_ids.map{|id|
        Mindmap.find(id)
      }.compact
    end
  end

  module CooperationUserMethods
    def self.included(base)
      base.after_create :change_user_cooperate_mindmaps_cache_on_create
      base.after_destroy :change_user_cooperate_mindmaps_cache_on_destroy
    end

    def change_user_cooperate_mindmaps_cache_on_create
      return true if self.user.blank?
      UserCooperateMindmapsProxy.new(self.user).add_to_cache(self.mindmap_id)
      return true
    end

    def change_user_cooperate_mindmaps_cache_on_destroy
      return true if self.user.blank?
      UserCooperateMindmapsProxy.new(self.user).remove_from_cache(self.mindmap_id)
      return true
    end
  end
end
