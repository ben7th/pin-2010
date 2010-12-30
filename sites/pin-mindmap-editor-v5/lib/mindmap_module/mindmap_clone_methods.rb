module MindmapCloneMethods
  def mindmap_clone(user,attributes)
    title = attributes[:title] || self.title
    struct = self.struct
    mindmap = Mindmap.create!(:private=>self.private,:clone_from=>self.id,:user_id=>user.id,:title=>title,:struct=>struct)
    repo = self.note_repo
    MpGitTool.fork(repo,mindmap.note_repo_path) if !repo.blank?
    mindmap
  end
end