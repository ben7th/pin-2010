class MindmapRank

  require 'nokogiri'

  def initialize(mindmap)
    @mindmap = mindmap
    @struct_xml_content = Nokogiri::XML(mindmap.struct)
  end

  def weight_value
    return 0 if @mindmap.struct.nil?
    node_count + (leaf_count * deep)
  end

  # 所有节点数
  def node_count
    nodes.size - 1
  end

  # 叶子节点数,把标题为newsubnode的节点去除
  def leaf_count
    return 0 if nodes.size == 1
    nodes.select do |node|
      node.css("N").size == 0 && node['t'] != "NewSubNode"
    end.size
  end

  # 层数
  def deep 
    root_node = @struct_xml_content.at("N")
    layer_count(root_node)
  end

  def layer_count(node)
    return 0 if node.nil? || node.children.size == 0
    node.children.map{|child|layer_count(child)}.max+1
  end

  # 所有的节点（把标题为newsubnode的节点去除）
  def nodes
    @struct_xml_content.css("N").select do |node|
      node['t']!="NewSubNode"
    end
  end

  # 计算rank值
  def rank_value
    format('%.1f',(Math.log(@mindmap.weight+1)/Math.log(MindmapRank.map_max_weight+1))*10).to_f
  end

  # 获取 map_max_weight
  def self.map_max_weight
    # 存放在硬盘文件上
    file_path = File.join(RAILS_ROOT, "config", "map_max_weight")

    if !File.exist?(file_path)
      mmw = Mindmap.maximum("weight") || 0
      self.map_max_weight=(mmw)
      return mmw
    else
      return File.new(file_path,"r").read.to_i
    end
  end

  # 设置 map_max_weight
  def self.map_max_weight=(mmw)
    file_path = File.join(RAILS_ROOT, "config", "map_max_weight")
    File.open(file_path,"w"){|f| f << mmw}
  end

end
