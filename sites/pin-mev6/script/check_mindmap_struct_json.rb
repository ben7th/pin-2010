mindmaps = Mindmap.order("id asc").select("id").all
count = mindmaps.length

mindmaps.each_with_index do |m,i|
  p "正在处理 #{i+1}/#{count}"
  mindmap = Mindmap.find(m.id)
  
  begin
    mindmap.struct_json
  rescue Exception => ex
    l = Logger.new("/web/2010/logs/check_mindmaps_struct_json.log")
    l.error(ex.message)
    l.error(ex.backtrace*"\n")
    l.error("mindmap #{mindmap.id}")
    l.error("~~~~~~~")
  end
end

