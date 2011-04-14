module MindmapFavProxy
  module MindmapFavMethods
    def self.included(base)
      base.after_create :change_fav_cache_on_create
      base.after_destroy :change_fav_cache_on_destroy
    end

    def change_fav_cache_on_create
      MindmapFavUsersProxy.new(self.mindmap).add_to_cache(self.user_id)
      UserFavMindmapsProxy.new(self.user).add_to_cache(self.mindmap_id)
    end

    def change_fav_cache_on_destroy
      MindmapFavUsersProxy.new(self.mindmap).remove_from_cache(self.user_id)
      UserFavMindmapsProxy.new(self.user).remove_from_cache(self.mindmap_id)
    end
  end

  module UserMethods
    def fav_mindmaps(paginate_option={})
      mindmap_ids = UserFavMindmapsProxy.new(self).xxxs_ids
      if paginate_option.blank?
        first = 0
        count = mindmap_ids.count
      else
        first = paginate_option[:per_page].to_i*(paginate_option[:page].to_i-1)
        count = paginate_option[:per_page].to_i
      end
      _mindmaps = []
      mindmap_ids[first..-1].each do |id|
        mindmap = Mindmap.find_by_id(id)
        if !mindmap.nil?
          _mindmaps.push(mindmap)
        end
        break if _mindmaps.count >= count
      end
      _mindmaps
    end
  end

  module MindmapMethods
    def fav_users
      MindmapFavUsersProxy.new(self).xxxs_ids.map{|id|User.find_by_id(id)}
    end
  end
end
