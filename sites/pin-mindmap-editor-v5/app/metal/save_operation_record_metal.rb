require "pie-service-lib"
class SaveOperationRecordMetal < BaseMetal 
  def self.routes
    {:method=>'PUT',:regexp=>/mindmaps\/do/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(env).params

    opers = ActiveSupport::JSON.decode(params["operations"])
    mindmap = Mindmap.find(params["map"])

    if !mindmap.check_md5(params["md5"])
      return [422,{"Content-Type" => "text/xml"}, ["md5值不匹配，需要#{mindmap.md5}，提交为#{params["md5"]}"]]
    end
    
    opers.each do |op|
      mindmap.do_operation(op)
    end
    return [200, {"Content-Type" => "text/x-json"}, [{:md5=>mindmap.md5}.to_json]]
  end
end
