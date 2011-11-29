mindmaps = Mindmap.find(:all,:select=>"id",:order=>"id asc")
count = mindmaps.length

mindmaps.each_with_index do |mindmap,index|
  p "正在处理 mindmap_#{mindmap.id} #{index+1}/#{count}"

  m = Mindmap.find(mindmap.id)

  ms = MindmapScope.find_by_mindmap_id(m.id)
  if ms.blank?
    bool_private = !!m.attributes["private"]
    param = ""
    if bool_private
      param = MindmapScope::PRIVATE
    else
      param = MindmapScope::ALL_PUBLIC
    end

    MindmapScope.create(:mindmap=>m,:param=>param)
  end
end
  