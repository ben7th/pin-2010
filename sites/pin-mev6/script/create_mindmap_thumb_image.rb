mindmaps = Mindmap.find(:all,:select=>"id",:order=>"id desc")
count = mindmaps.length

mindmaps.each_with_index do |mindmap,index|
  p "正在处理 #{index+1}/#{count}"

  m = Mindmap.find_by_id(mindmap.id)
  p "把 mindmap #{m.id} 放入生成缩略图队列..."
  m.refresh_thumb_image_in_queue
end