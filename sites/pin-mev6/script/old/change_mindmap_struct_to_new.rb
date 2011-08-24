mindmaps = Mindmap.find(:all,:select=>"id",:order=>"id desc")
count = mindmaps.length

  mindmaps.each_with_index do |mindmap,index|
    p "正在处理 #{index+1}/#{count}"

    m = Mindmap.find_by_id(mindmap.id)
    MindmapChangeStruct.new(m).change_struct_to_new
  end
  