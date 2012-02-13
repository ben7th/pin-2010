mindmaps = Mindmap.order("id asc").select("id").all
count = mindmaps.length

mindmaps.each_with_index do |m,i|
  p "正在处理 #{i+1}/#{count}"
  
  begin
    
    mindmap = Mindmap.find(m.id)
    status = mindmap.send_status
    status ="public" if status.blank?
    
    next if status == "private"
    
    
    ma = MindmapAlbum.find_or_create_by_user_id_and_title_and_send_status(mindmap.user.id,"公开导图","public")
    
    mindmap.mindmap_album = ma
    
    mindmap.instance_variable_set(:@skip_hook,"skip")
    mindmap.save_without_timestamping
    
    
  rescue Exception => ex
    l = Logger.new("/web/2010/logs/migrate_public_mindmap_send_status_to_mindmap_album.log")
    l.error(ex.message)
    l.error(ex.backtrace*"\n")
    l.error("mindmap #{mindmap.id}")
    l.error("~~~~~~~")
  end
  
  
end  