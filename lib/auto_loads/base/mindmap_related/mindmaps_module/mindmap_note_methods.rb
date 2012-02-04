module MindmapNoteMethods
  def newest_note_of_node(node_id)
    self.notes.where(:node_id=>node_id).order("version desc").first
  end
  
  # 删除节点备注
  def destroy_node_note(node_id)
    note = self.newest_note_of_node(node_id)
    return if note.blank?
    new_version = note.version+1
    self.notes.create(:node_id=>node_id,:version=>new_version)
  end
  
  # 增加节点备注
  def update_node_note(node_id,note_text)
    note = self.newest_note_of_node(node_id)
    new_version = (note.blank? ? 0 : note.version+1)
    self.notes.create(:node_id=>node_id,:content=>note_text,:version=>new_version)
  end
  
  # 所有备注
  def node_notes
    node_notes_hash = Hash.new
    node_notes_temp_hash = Hash.new
    self.notes.each do |note|
      node_notes_temp_hash[note.node_id]||=[]
      node_notes_temp_hash[note.node_id].push(note)
    end
    node_notes_temp_hash.each{|k,v|v.sort!{|b,a|a.version<=>b.version}}
    node_notes_temp_hash.each do |node_id,notes|
     next if notes.first.content.blank?
      node_notes_hash[node_id] = notes.first.content
    end
    
    node_notes_hash
  end
  
end