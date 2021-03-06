module MindmapToImageHashMethods
  # 根据传入的xml字符串计算包括尺寸数据的 map_hash
  def get_nodes_hash(xmlstr)
    doc = Nokogiri::XML xmlstr
    node = doc.at('mindmap>node')
    get_nodes_locations(_build_node_hash(node))
  end

  # 组织节点数据，导出用
  def _build_node_hash(node)
    re = _build_hash_include_id_title_width_height(node)
    re.merge!(_get_extra_hash(node))
    re.merge! :children=>node.xpath("./node").map {|child| _build_node_hash(child)}
    re
  end

  def get_nodes_hash_thumb(xmlstr)
    doc = Nokogiri::XML xmlstr
    node = doc.at('mindmap>node')
    get_nodes_locations(_build_node_hash_thumb(node,0))
  end

  # 组织节点数据，生成缩略图用
  def _build_node_hash_thumb(node,depth)
      re = _build_hash_include_id_title_width_height(node)
      re.merge!(_get_extra_hash(node))
      depth = depth + 1
      if depth < 4
        re.merge! :children=>node.xpath("./node").map {|child| _build_node_hash_thumb(child,depth)}
      else
        count = node.css("node").length
        if count > 0
          dim = get_text_size(count.to_s)
          re.merge! :children=>[
            {
              :title  => count.to_s,
              :width  => dim[:width],
              :height => dim[:height],
              :putright=> _get_extra_hash(node),
              :children => []
            }
          ]
          re.merge! :has_thumb=>true
        else
          re.merge! :children=>[]
        end
      end
      return re
  end

  def _build_hash_include_id_title_width_height(node)
    title = node["title"] # "\\" 这样的字符串结尾会导致生成图片时出错，参考开发环境 mindmap[id=99]
    title = "#{title}\\" if title.last == '\\'
    dim = get_text_size(title)
    
    if has_uploaded_img?(node)
      image = MindmapNodeImage.new(node)

      imgw = image.width * zoom
      imgh = image.height * zoom
      img_file_path = image.path

      return {
        :id     => node["id"],
        :title  => title,
        :width  => [dim[:width],imgw].max,
        :height => dim[:height]+imgh,
        :bgcolor => node[:bgcolor],
        :textcolor => node[:textcolor],
        :inner_img_filepath => img_file_path,
        :imgw => imgw,
        :imgh => imgh,
        :text_height => dim[:height]
      }
    else
      return {
        :id     => node["id"],
        :title  => title,
        :width  => dim[:width],
        :height => dim[:height],
        :bgcolor => node[:bgcolor],
        :textcolor => node[:textcolor]
      }
    end
  end

  def has_uploaded_img?(node)
    node[:img_attach_id]
  end

  def _get_extra_hash(node)
    return {:is_root=>true} if _node_is_root?(node)
    {:putright=>_node_is_put_on_right?(node)}
  end

  def _node_is_put_on_right?(node)
    parent = node.parent
    return (node["pos"] != 'left') if _node_is_root?(parent)
    _node_is_put_on_right?(parent)
  end

  def _node_is_root?(node)
    node.parent.name == "mindmap"
  end

  ##########################################################
  ##### 重构预备

  def get_nodes_locations(root)
    # 根结点

    # 递归计算所有一级子节点坐标

    left_nodes = root[:children].select{|x| !x[:putright]}
    right_nodes = root[:children].select{|x| x[:putright]}

    left_subtrees_total_height = left_nodes.map{|child| locations_recursion(root,child)}.sum
    right_subtrees_total_height = right_nodes.map{|child| locations_recursion(root,child)}.sum

    root[:left_subtree_width] =  left_nodes.map{|x| x[:subtree_width]}.max || 0
    root[:right_subtree_width] = right_nodes.map{|x| x[:subtree_width]}.max || 0

    # 根节点上的位置数据信息
    root_height = root[:height]

    if right_subtrees_total_height > root_height
      root[:cy_off] = 0
    else
      root[:cy_off] = (root_height - right_subtrees_total_height) / 2
    end

    root[:left_total_subtree_height] = left_subtrees_total_height
    root[:right_total_subtree_height] = right_subtrees_total_height

    max_height = [left_subtrees_total_height, right_subtrees_total_height, root_height].max

    # 左侧所有节点的顶坐标
    root[:left_children_top]  = (max_height - left_subtrees_total_height) / 2
    # 右侧所有节点的顶坐标
    root[:right_children_top] = (max_height - right_subtrees_total_height) / 2

    root[:y_off]=(max_height - root_height)/2

    root[:x] = 0
    root[:y] = root[:y_off]

    root[:max_height] = max_height

    return root
  end

  def locations_recursion(parent,node)
    children_total_height = _get_children_total_height_of_node(node)
    
    subtree_width = _get_subtree_width_of_node(node)
    node[:subtree_width] = subtree_width

    self_height = node[:height]

    subtree_height = 0

    # 节点和节点下级节点的对齐方式
    # 2011-7-12 改成和导图编辑器一样的对齐方式
    children = node[:children]
    if children.length == 0
      node[:cy_off] = 0
      node[:y_off] = 0
      subtree_height = self_height + v_padding
    else
      first_child = children[0]
      last_child = children[-1]

      first_child_baseline_yoff = first_child[:y_off] + first_child[:height]
      last_child_baseline_bottom_off = last_child[:subtree_height] - (last_child[:y_off] + last_child[:height])
      last_child_baseline_yoff = children_total_height - last_child_baseline_bottom_off

      baseline_diff = last_child_baseline_yoff - first_child_baseline_yoff

      ref_height = baseline_diff / 2 + first_child_baseline_yoff
      others_height = baseline_diff / 2 + last_child_baseline_bottom_off

      if ref_height > self_height
        node[:cy_off] = 0 # children y offset
        node[:y_off] = ref_height - self_height
        subtree_height = ref_height + [others_height, v_padding].max
      else
        node[:cy_off] = self_height - ref_height
        node[:y_off] = 0
        subtree_height = self_height + [others_height, v_padding].max
      end
    end

    node[:subtree_height] = subtree_height

    if(parent[:is_root])
      node[:cy_off] = node[:cy_off] - parent[:height]/2
      node[:y_off] = node[:y_off] - parent[:height]/2
    end

    return subtree_height
  end

  def _get_children_total_height_of_node(node)
    children = node[:children]

    children.map { |child|
      locations_recursion(node,child)
    }.sum
  end

  def _get_subtree_width_of_node(node)
    # 如果有孩子，取所有孩子宽度的最大值来累加
    children = node[:children]
    children_width = children.map{|child| child[:subtree_width]}.max || 0
    node[:width] + children_width + width_margin
  end

  #############################################################
  #### 以上须重构

end
