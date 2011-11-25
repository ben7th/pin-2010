module MindmapSnapshotMethods
  # 创建导图快照
  def create_snapshot(message="")
    create_note_repo_if_unexist
    repo = self.note_repo
    write_hash = self.node_file_notes
    write_hash["struct.xml"] = self.struct
    message = "导图快照" if message.blank?
    command_res_str = MpGitTool.add_text_content!(repo,self.user,write_hash,message)
    raise "no change" if !!command_res_str.match("nothing to commit")
    return true
  rescue Exception=>ex
    raise CreateSnapshotNoContentChangeError,"内容没有变化，无法保存快照" if ex.message == "no change"
    raise CreateSnapshotError,"创建导图快照时，出现错误"
  end

  def snapshot_commits
    repo = self.note_repo
    return [] if repo.blank?
    MpGitTool.ref_commits(repo,"struct.xml")
  end

  def snapshot_cids
    self.snapshot_commits.map{|commit|commit.id}
  end

  # 恢复一个快照
  def recover_snapshot(snapshot_cid)
    repo = self.note_repo
    # 恢复 struct
    struct = repo.commit(snapshot_cid).tree./("struct.xml").data
    self.update_attributes(:struct=>struct)
    # 恢复版本库备注
    repo.rollback(snapshot_cid)
    return true
  rescue
    raise RecoverSnapshotError,"恢复快照时，出现错误"
  end

  class CreateSnapshotNoContentChangeError < StandardError;end
  class CreateSnapshotError < StandardError;end
  class RecoverSnapshotError < StandardError;end

end
