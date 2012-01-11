mindmaps = Mindmap.order("id asc").select("id").all
count = mindmaps.length

base_path = "/web/2010/daotu_files/notes"
FileUtils.mkdir_p(base_path) if !File.exist?(base_path)

mindmaps.each_with_index do |m,i|
  p "正在处理 #{i+1}/#{count}"
  
  begin
    mindmap = Mindmap.find(m.id)
    has_note = !mindmap.note_nid.blank? && File.exist?(File.join('/web/2010/note_repo/notes',mindmap.note_nid))
    old_path = File.join('/web/2010/note_repo/notes',mindmap.note_nid)
    next if !has_note
    
    p "移动 mindmap #{mindmap.id} 备注"
    new_prefix_path = File.dirname(mindmap.note_repo_path)
    FileUtils.mkdir_p(new_prefix_path) if !File.exist?(new_prefix_path)
    FileUtils.move(old_path,mindmap.note_repo_path)
  rescue Exception => ex
    l = Logger.new("/web/2010/logs/migrate_mindmap_note.log")
    l.error(ex.message)
    l.error(ex.backtrace*"\n")
    l.error("mindmap #{mindmap.id}")
    l.error("~~~~~~~")
  end
end

