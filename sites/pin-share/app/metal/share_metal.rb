require "pie-service-lib"
class ShareMetal < BaseMetal
  def self.routes
    {:method=>'POST',:regexp=>/^\/shares.xml/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Hash.from_xml(env["rack.input"].read)
    share = Share.create!(params['share'])
    return [200, {"Content-Type" => "text/xml"}, [share.to_xml]]
  end
end