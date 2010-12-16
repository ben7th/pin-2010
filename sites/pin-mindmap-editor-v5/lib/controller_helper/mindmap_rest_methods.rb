module MindmapRestMethods
  def mindmaps_json(mindmaps)
    mindmaps_hash_arr = mindmaps.map do |mindmap|
      mindmap_json(mindmap)
    end
    {:mindmaps=>mindmaps_hash_arr}
  end

  def mindmap_json(mindmap)
    {:id=>mindmap.id,:title=>mindmap.title,:updated_at=>mindmap.updated_at,:created_at=>mindmap.created_at}
  end
end