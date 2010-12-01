module MindmapRestMethods
  def mindmaps_json(mindmaps)
    mindmaps_hash_arr = mindmaps.map do |mindmap|
      {:id=>mindmap.id,:title=>mindmap.title,:updated_at=>mindmap.updated_at,:created_at=>mindmap.created_at}
    end
    {:mindmaps=>mindmaps_hash_arr}
  end
end