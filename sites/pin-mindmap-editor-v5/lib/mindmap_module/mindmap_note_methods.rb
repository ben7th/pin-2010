require 'net/http'
require 'uri'

module MindmapNoteMethods
  if RAILS_ENV == "production"
    FORK_NOTE_URL = "http://notes.mindpin.com/notes/mindmap_fork"
  else
    FORK_NOTE_URL = "http://dev.notes.mindpin.com/notes/mindmap_fork"
  end
  
  NOTE_REPO_BASE_PATH = YAML.load(CoreService.project("pin-notes").settings)["note_repo_path"]

  def add_note_file_url
    note_nid = self.note_nid
    if RAILS_ENV == "production"
      return "http://notes.mindpin.com/notes/#{note_nid}/add_file"
    else
      return "http://dev.notes.mindpin.com/notes/#{note_nid}/add_file"
    end
  end

  def delete_note_file_url
    note_nid = self.note_nid
    if RAILS_ENV == "production"
      return "http://notes.mindpin.com/notes/#{note_nid}/delete_file"
    else
      return "http://dev.notes.mindpin.com/notes/#{note_nid}/delete_file"
    end
  end

  def self.included(base)
    base.after_create :save_note_nid
  end

  # 每一个 mindmap 都有一个 note
  def save_note_nid
    nid = create_fork_note
    self.update_attribute(:note_nid,nid)
  end

  def create_fork_note
    email = self.user ? self.user.email : "nobody@mindpin.com"
    mindmap_id = self.id
    url = URI.parse(FORK_NOTE_URL)
    site = Net::HTTP.new(url.host, url.port)
    site.open_timeout = 20
    site.read_timeout = 20
    path = url.query.blank? ? url.path : url.path+"?"+url.query
    return site.post2(path,URI.escape("email=#{email}&mindmap_id=#{mindmap_id}"),{'accept'=>'text/html','user-agent'=>'Mozilla/5.0'}).body
  end

  # 删除节点备注
  def destroy_node_note(local_id)
    file_name = "notefile_#{local_id}"
    data = URI.escape("name=#{file_name}")

    url_str = delete_note_file_url
    url = URI.parse(url_str)
    site = Net::HTTP.new(url.host, url.port)

    site.open_timeout = 20
    site.read_timeout = 20

    site.request(Net::HTTP::Delete.new(url.path,{'accept'=>'text/html','user-agent'=>'Mozilla/5.0'}),data)
  end

  # 增加节点备注
  def update_node_note(local_id,note)
    file_name = "notefile_#{local_id}"
    file_content = note
    format = "text"
    data = URI.escape("format=#{format}&name=#{file_name}&content=#{file_content}")

    url_str = add_note_file_url
    url = URI.parse(url_str)
    site = Net::HTTP.new(url.host, url.port)

    site.open_timeout = 20
    site.read_timeout = 20
    site.request(Net::HTTP::Put.new(url.path,{'accept'=>'text/html','user-agent'=>'Mozilla/5.0'}),data)
  end

  # 所有备注
  def node_notes
    repo = Grit::Repo.new(File.join(NOTE_REPO_BASE_PATH,"notes",self.note_nid))
    commit = repo.commit("master")
    contents = commit ? commit.tree.contents : []
    blobs = contents.select do |item|
      item.instance_of?(Grit::Blob) && item.name != ".git" && item.name.match("notefile_")
    end
    note_hash = {}
    blobs.each{|blob|note_hash[blob.name.gsub("notefile_","")] = blob.data}
    note_hash
  rescue
    {}
  end

end