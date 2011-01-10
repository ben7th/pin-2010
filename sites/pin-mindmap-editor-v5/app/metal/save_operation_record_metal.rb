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

    if !mindmap.check_revision(params["revision"].to_i)
      return [422,{"Content-Type" => "text/xml"}, ["revision值不匹配，需要#{mindmap.revision}，提交为#{params["revision"]}"]]
    end
    
    begin
      opers.each do |op|
        mindmap.do_operation(op)
      end
      return [200, {"Content-Type" => "text/x-json"}, [{:revision=>mindmap.revision}.to_json]]
    rescue Exception => ex
      return [500, {"Content-Type" => "text/x-json"}, [{:error=>ex.message}.to_json]]
    end

  end
end
