module MindmapCloneMethods
  def mindmap_clone(user,attributes)
    title = attributes[:title] || self.title
    struct = self.struct
    mindmap = Mindmap.create!(:private=>self.private,:clone_from=>self.id,:user_id=>user.id,:title=>title,:struct=>struct)
    self.nodes.each do |node|
      local_id = node.local_id
      note = node.note
      mindmap.nodes.create!(:local_id=>local_id,:note=>note)
    end
    mindmap
  end
end