class MindmapChangeStruct

  def initialize(mindmap)
    @mindmap = mindmap
  end

   # 改变struct的结构
  def change_struct_to_new
    doc = Nokogiri::XML(@mindmap.struct)
    root = doc.css("Nodes")[0]
    root.name = "mindmap"
    root["ver"] = "0.5"
    root.remove_attribute("maxid")
    doc.css("N").each do |node|
      node.name = "node"
      node["title"] = node["t"]
      node.remove_attribute("t")
      if !node["f"].blank?
        node["closed"] = node["f"]=="0" ? "false" : "true"
        node.remove_attribute("f")
      end
      if !node["i"].blank?
        node["image"] = node["i"]
        node["imgw"] = node["iw"]
        node["imgh"] = node["ih"]
        node.remove_attribute("i")
        node.remove_attribute("iw")
        node.remove_attribute("ih")
      end
    end
    new_struct = doc.to_s
    @mindmap.struct = new_struct
    @mindmap.save
  end
  
end
