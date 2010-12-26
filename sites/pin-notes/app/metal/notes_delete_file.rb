require "pie-service-lib"
class NotesDeleteFile < BaseMetal
  def self.routes
    {:method=>'DELETE',:regexp=>/\/notes\/(\w+)\/delete_file/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    env = hash[:env]

    nid = url_match[1]
    params = Rack::Request.new(env).params
    note = Note.find_by_id(nid) || Note.find_by_private_id(nid)

    note.delete_file!(params["name"])

    return [200, {"Content-Type" => "text/xml"}, [note.nid]]
  end
end