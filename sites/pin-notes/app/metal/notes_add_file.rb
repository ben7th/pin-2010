require "pie-service-lib"
class NotesAddFile < BaseMetal
  def self.routes
    {:method=>'PUT',:regexp=>/\/notes\/(\w+)\/add_file/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    env = hash[:env]

    nid = url_match[1]
    params = Rack::Request.new(env).params

    if params["format"] == "text"
      note = Note.find_by_id(nid) || Note.find_by_private_id(nid)
      note.add_text_content!(params["name"],params["content"])
    end

    return [200, {"Content-Type" => "text/xml"}, [note.nid]]
  end
end