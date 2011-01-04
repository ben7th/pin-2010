require "pie-service-lib"
class TogglePrivateMindmapMetal < BaseMetal
  def self.routes
    {:method=>'PUT',:regexp=>/mindmaps\/(.+)\/toggle_private/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    mindmap_id = url_match[1]
    mindmap = Mindmap.find(mindmap_id)
    if self.is_allowed_modify(mindmap)
      return [200, {"Content-Type" => "text/xml"}, ["ok"]] if mindmap.toggle_private
    end
    return [403, {"Content-Type" => "text/xml"}, ["forbidden"]]
  end

  def self.is_allowed_modify(mindmap)
    #current_user.id == mindmap.user_id
    return true
  end
end
