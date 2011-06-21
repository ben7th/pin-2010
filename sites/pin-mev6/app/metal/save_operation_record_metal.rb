class SaveOperationRecordMetal < BaseMetal 
  def self.routes
    {:method=>'PUT',:regexp=>/mindmaps\/do/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(env).params

    mindmap = Mindmap.find(params["map"])
    current_user = self.current_user(env)
    opers = ActiveSupport::JSON.decode(params["operations"])
    revision = ActiveSupport::JSON.decode(params["revision"])
    local_revision = revision["local"].to_i
    mup_ap "~~~~ts~~~~~~"
    mup_ap "params[:local_revision] : #{local_revision}  "
    mup_ap "mindmap_revision : #{mindmap.revision}"
    mup_ap "~~~~ts~~~~~~"

    if !mindmap.has_edit_rights?(current_user)
      return [403,{"Content-Type" => "text/xml"}, [{:code=>MindmapOperate::ErrorCode::ACCESS_NOT_VALID}.to_json]]
    end

    if mindmap.revision != local_revision
      return [422,{"Content-Type" => "text/xml"}, [{:code=>MindmapOperate::ErrorCode::REVISION_NOT_VALID}.to_json]]
    end

    begin
      opers.each do |oper|
        MindmapOperate.new(mindmap,oper,current_user).do_operation
      end
      return [200, {"Content-Type" => "text/x-json"}, [{:revision=>mindmap.revision}.to_json]]
    rescue MindmapOperate::NodeNotExistError => nnee
      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::NODE_NOT_EXIST}.to_json]]
    rescue MindmapOperate::MindmapNotSaveError => mns
      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::MINDMAP_NOT_SAVE}.to_json]]
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace*"\n"
      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::UNKNOWN}.to_json]]
    end
    
  end
end
