class SaveOperationRecordMetal < BaseMetal 
  def self.routes
    {:method=>'PUT',:regexp=>/mindmaps\/do/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(env).params
#    {
#     "map" => 25755
#     "revision"	=> {
#       "local"	=> 100
#       "remote" => 100
#       }
#     "operation" => op
#    }
    mindmap = Mindmap.find(params["map"])
    current_user = self.current_user(env)
    oper = ActiveSupport::JSON.decode(params["operation"])
    revision = ActiveSupport::JSON.decode(params["revision"])

    if !MindpinServiceManagement.resque_queue_worker_start?("mindmap_input_resque_queue")
      return [406,{"Content-Type" => "text/xml"}, ["编辑处理服务没有启动"]]
    end

    if !mindmap.has_edit_rights?(current_user)
      return [403,{"Content-Type" => "text/xml"}, ["你没有权限编辑该导图"]]
    end

    # 考虑到协同编辑时的并发问题，不再检查revision
#    if !mindmap.check_revision(params["revision"].to_i)
#      return [422,{"Content-Type" => "text/xml"}, ["revision值不匹配，需要#{mindmap.revision}，提交为#{params["revision"]}"]]
#    end
    
#    begin
#      opers.each do |op|
#        MindmapOperate.new(mindmap,op,current_user).do_operation
#      end
#      MindmapOperationProxy.new(mindmap).add_to_mindmap_operation_vector_cache({:map=>params["map"],:operations=>opers,:revision=>params["revision"],:user_id=>current_user.id,:new_revision=>mindmap.document.revision})
#      return [200, {"Content-Type" => "text/x-json"}, [{:revision=>mindmap.revision}.to_json]]
#    rescue MindmapOperate::NodeNotExistError => nnee
#      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::NODE_NOT_EXIST}.to_json]]
#    rescue MindmapOperate::MindmapNotSaveError => mns
#      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::MINDMAP_NOT_SAVE}.to_json]]
#    rescue Exception => ex
#      puts ex.message
#      puts ex.backtrace*"\n"
#      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::UNKNOWN}.to_json]]
#    end
#    
    # 02-11 通过消息队列结合DOPT算法对编辑请求进行调度
    begin
#      mq = MindmapInputQueue.new
#      mq.push({
#          :op   => oper,
#          :user => current_user.email,
#          :map  => mindmap.id,
#          :rev  => {
#            :local=>revision["local"],
#            :remote=>revision["remote"]
#          }
#        }.to_json) # 放入消息队列后，由后台进程处理

      operate_json = {
        :op   => oper,
        :user => current_user.email,
        :map  => mindmap.id,
        :rev  => {
          :local=>revision["local"],
          :remote=>revision["remote"]
        }
      }.to_json
      MindmapInputQueueResqueWorker.async_mindmap_input_queue(operate_json)
      return [200, {"Content-Type" => "text/x-json"}, [{:revision=>mindmap.revision}.to_json]]
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace*"\n"
      return [500, {"Content-Type" => "text/x-json"}, [{:code=>MindmapOperate::ErrorCode::UNKNOWN,:message=>ex.message}.to_json]]
    end
    
  end
end
