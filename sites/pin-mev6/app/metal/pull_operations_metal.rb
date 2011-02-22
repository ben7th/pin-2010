class PullOperationsMetal < BaseMetal
  def self.routes
    {:method=>'get',:regexp=>/mindmaps\/pull/}
  end

  def self.deal(hash)
    env = hash[:env]
    current_user = self.current_user(env)
    params = Rack::Request.new(env).params
    mindmap_id = params["map"]
    revision = ActiveSupport::JSON.decode(params["revision"])
    rev_local = revision["local"]
    rev_remote = revision["remote"]
    mindmap = Mindmap.find(mindmap_id)
    operations = MindmapBroadcastQueue.new(mindmap).get_by_conditions(current_user,rev_local,rev_remote)
    return [200, {"Content-Type" => "text/x-json"}, [operations.to_json]]
  rescue Exception=>ex
    puts ex.backtrace.join("\n")
    return [500, {"Content-Type" => "text/x-json"}, [ex.message.to_json]]
  end
end
