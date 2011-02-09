require "pie-service-lib"
class PullOperationsMetal < BaseMetal
  def self.routes
    {:method=>'get',:regexp=>/mindmaps\/pull/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(env).params
    mindmap_id = params["map"]
    revision = params["revision"]
    mindmap = Mindmap.find(mindmap_id)
    operations = MindmapOperationProxy.new(mindmap).operations(revision)
    return [200, {"Content-Type" => "text/x-json"}, [operations.to_json]]
  rescue Exception=>ex
    puts ex.backtrace.join("\n")
    return [500, {"Content-Type" => "text/x-json"}, [ex.message.to_json]]
  end
end
