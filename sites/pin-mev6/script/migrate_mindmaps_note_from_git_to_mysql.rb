class MindmapGitNote
  NOTE_REPO_BASE_PATH = '/web/2010/daotu_files/notes'
  def initialize(mindmap)
    @mindmap = mindmap
  end
  
  def node_notes
    node_notes_hash = Hash.new('')
    self.node_file_notes.each{|name,data|node_notes_hash[name.gsub("notefile_","")] = data}
    node_notes_hash
  end
  
  def node_file_notes
    repo = self.note_repo
    commit = repo.commit("master")
    contents = commit ? commit.tree.contents : []
    blobs = contents.select do |item|
      item.instance_of?(Grit::Blob) && item.name != ".git" && item.name.match("notefile_")
    end
    node_file_notes_hash = {}
    blobs.each{|blob|node_file_notes_hash[blob.name] = blob.data}
    node_file_notes_hash
  rescue
    {}
  end
  
  def note_repo
    create_note_repo_if_unexist
    Grit::Repo.new(note_repo_path)
  end
  
  def create_note_repo_if_unexist
    if !self.note_repo_exist?
      MpGitTool.init_repo(note_repo_path)
    end
  end
  
  def note_repo_path
    raise "mindmap id is null" if @mindmap.id.blank?
    
    asset_id = (@mindmap.id / 1000).to_s
    File.join(NOTE_REPO_BASE_PATH,asset_id,@mindmap.id.to_s)
  end
  
  def note_repo_exist?
    !@mindmap.id.blank? && File.exist?(note_repo_path)
  end
  
end


mindmaps = Mindmap.order("id asc").select("id").all
count = mindmaps.length

mindmaps.each_with_index do |m,i|
  p "正在处理 #{i+1}/#{count}"
  
  begin
    
    mindmap = Mindmap.find(m.id)
    mgn = MindmapGitNote.new(mindmap)
    next if !mgn.note_repo_exist?
    
    mgn.node_notes.each do |node_id,text|
      mindmap.update_node_note(node_id,text)
    end
    
  rescue Exception => ex
    l = Logger.new("/web/2010/logs/migrate_mindmap_note_from_git_to_mysql.log")
    l.error(ex.message)
    l.error(ex.backtrace*"\n")
    l.error("mindmap #{mindmap.id}")
    l.error("~~~~~~~")
  end
  
  
end  













