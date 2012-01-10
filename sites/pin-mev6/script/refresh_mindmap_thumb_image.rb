mindmaps = Mindmap.order("id asc").select("id").all
count = mindmaps.length

mindmaps.each_with_index do |m,i|
  p "正在处理 #{i+1}/#{count}"
  mindmap = Mindmap.find(m.id)
  mindmap.refresh_thumb_image
end
