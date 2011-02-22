class RecentlyMindmapsMetal < BaseMetal 
  def self.routes
    {:method=>'GET',:regexp=>/users\/(.+)\/mindmaps\/recently/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    user_id = url_match[1]
    mindmaps = User.find(user_id).recently_mindmaps
    xml = mindmaps.to_xml(:only=>[:id,:title],:methods=>:logo)
    return [200, {"Content-Type" => "text/xml"}, [xml]]
  end
end
