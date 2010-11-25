require "pie-service-lib"
class SaveOperationRecordMetal < BaseMetal 
  def self.routes
    {:method=>'PUT',:regexp=>/mindmaps\/do/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(env).params

    opers = ActiveSupport::JSON.decode(params["operations"])
    opers.each do |op|
      mindmap = User.find(params["req_user_id"]).mindmaps.find(op['map'])
      mindmap.do_operation(op)
    end
    return [200, {"Content-Type" => "text/xml"}, ['ok']]
  end
end
