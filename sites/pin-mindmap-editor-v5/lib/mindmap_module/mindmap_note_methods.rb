module MindmapNoteMethods
  NOTE_REPO_BASE_PATH = YAML.load(CoreService.project("pin-notes").settings)["note_repo_path"]

  def self.included(base)
    base.after_create :create_note_repo_if_unexist
  end

  # 如果备注版本库不存在，就创建一个
  def create_note_repo_if_unexist
    return self.note_nid if self.note_repo_exist?

    nid = self.note_nid
    nid = randstr(20) if nid.blank?
    
    MpGitTool.init_repo(File.join(NOTE_REPO_BASE_PATH,"notes",nid))

    self.update_attribute(:note_nid,nid)
    return nid
  end

  # 删除节点备注
  def destroy_node_note(local_id)
    file_name = "notefile_#{local_id}"
    repo = self.note_repo
    MpGitTool.delete_file!(repo,self.user,file_name)
  end

  # 增加节点备注
  def update_node_note(local_id,note)
    create_note_repo_if_unexist
    file_name = "notefile_#{local_id}"
    file_content = note
    repo = self.note_repo
    MpGitTool.add_text_content!(repo,self.user,{file_name=>file_content})
  end

  # 所有备注
  def node_notes
    node_notes_hash = {}
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

  # 备注对应的版本库是否存在
  def note_repo
    return nil if self.note_nid.blank?
    repo_path = note_repo_path
    return nil if !File.exist?(repo_path)
    Grit::Repo.new(repo_path)
  end

  def note_repo_path
    return "" if self.note_nid.blank?
    File.join(NOTE_REPO_BASE_PATH,"notes",self.note_nid)
  end

  # 备注版本库是否存在
  def note_repo_exist?
    !self.note_repo.blank?
  end

end