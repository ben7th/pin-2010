class MindmapEditRequest
  attr_reader :op
  attr_reader :user
  attr_reader :mindmap
  attr_reader :rev_local
  attr_reader :rev_remote

  def initialize(req_string)
    # req 结构
=begin
  {
    :op => oper,
    :user => current_user.email,
    :map  => mindmap.id,
    :rev  => {
      :local=>params["revision"]["local"],
      :remote=>params["revision"]["remote"]
    }
  }
=end
    req = ActiveSupport::JSON.decode(req_string)
    @user = EmailActor.get_user_by_email(req["user"])
    @op = req["op"]
    @mindmap = Mindmap.find(req["map"])
    @rev_local = req["rev"]["local"]
    @rev_remote = req["rev"]["remote"]
  end
  
  
  def push_to_mindmap_broadcast_queue
    json = {
      :map=>mindmap.id,
      :user=>user.email,
      :op=>op,
      :request_rev_remote=>rev_remote,
      :new_rev_remote=>mindmap.revision
    }.to_json
    mbq = MindmapBroadcastQueue.new(mindmap)
    mbq.push(json)
  end
  
end
