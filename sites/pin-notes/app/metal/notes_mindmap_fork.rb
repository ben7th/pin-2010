require "pie-service-lib"
class NotesMindmapFork < BaseMetal
  def self.routes
    {:method=>'POST',:regexp=>/\/notes\/mindmap_fork/}
  end

  def self.deal(hash)
    env = hash[:env]
    params = Rack::Request.new(env).params
    email = params["email"]
    mindmap_id = params["mindmap_id"]
    
    note = Note.mindmap_fork(email,mindmap_id)

    return [200, {"Content-Type" => "text/xml"}, [note.nid]]
  end
end