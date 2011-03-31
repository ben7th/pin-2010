class UserMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/^\/users\/(.+).xml/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    user_id = url_match[1]
    xml = User.find(user_id).to_xml(:only=>[:id,:name,:created_at],:methods=>:logo)
    return [200, {"Content-Type" => "text/xml"}, [xml]]
  end
end