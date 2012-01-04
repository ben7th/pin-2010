class MindmapChangeStruct

  def initialize(mindmap)
    @mindmap = mindmap
  end

  # 改变struct的结构
  def change_struct_to_new
    old_struct = @mindmap.struct.clone
    doc = Nokogiri::XML(@mindmap.struct)
    root = doc.css("Nodes")[0]
    return if root.blank?
    p "mindmap #{@mindmap.id} change struct ..."
    if root
      root.name = "mindmap"
      root["ver"] = "0.5"
      root.remove_attribute("maxid")
    end
    doc.css("N").each do |node|
      node.name = "node"
      node["title"] = node["t"]
      node.remove_attribute("t")
      if !node["f"].blank?
        node["closed"] = node["f"]=="0" ? "false" : "true"
        node.remove_attribute("f")
      end
      if !node["i"].blank?
        node["img"] = node["i"]
        node["imgw"] = node["iw"]
        node["imgh"] = node["ih"]
        node.remove_attribute("i")
        node.remove_attribute("iw")
        node.remove_attribute("ih")
      end
      if !node["pr"].blank?
        node["pos"] = node["pr"]=="0" ? "left" : "right"
        node.remove_attribute("pr")
      end
    end
    new_struct = doc.to_s
    @mindmap.struct = new_struct
    @mindmap.old_struct = old_struct
    # 临时用来跳过 创建 索引
    @mindmap.instance_variable_set(:@skip_hook,"skip")
    @mindmap.save_without_timestamping
  rescue Exception=>ex
    File.open(File.join(Rails.root,"/log/change_mindmap_log.log"),"a") do |file|
      file << "#{@mindmap.id} 出错啦"
      file << ex.to_s
      file << "\n"
    end
  end

  def self.change_all
    benchmark{
      Mindmap.all.each_with_index do |mindmap,index|
        p index+1
        benchmark{MindmapChangeStruct.new(mindmap).change_struct_to_new}
      end
    }
  end
  
end
