module MindmapNoteMethods
  NOTE_REPO_BASE_PATH = case RAILS_ENV
  when 'development'
    CoreService.find_setting_by_project_name("pin-notes")["note_repo_path"]
  when 'production'
    '/web/2010/note_repo' # 部署环境下note没有启动，加载不了，直接写了
  end

  # 如果备注版本库不存在，就创建一个
  def create_note_repo_if_unexist
    if !self.note_repo_exist?
      nid = randstr(20)
      MpGitTool.init_repo(File.join(NOTE_REPO_BASE_PATH,"notes",nid))
      self.update_attribute(:note_nid,nid)
    end
  end

  # 删除节点备注
  def destroy_node_note(local_id)
    file_name = "notefile_#{local_id}"
    repo = self.note_repo
    begin
      MpGitTool.delete_file!(repo,self.user,file_name)
    rescue Exception => ex
      p ex # 1月7日部署后，note提交会触发一个bug，先暂时这样fix
    end
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

  # 备注对应的版本库是否存在
  def note_repo
    create_note_repo_if_unexist
    Grit::Repo.new(note_repo_path)
  end

  # 备注的版本库路径
  def note_repo_path
    raise "note_nid is null" if self.note_nid.blank?
    File.join(NOTE_REPO_BASE_PATH,"notes",self.note_nid)
  end

  def note_repo_exist?
    !self.note_nid.blank? && File.exist?(File.join(NOTE_REPO_BASE_PATH,"notes",self.note_nid))
  end

end