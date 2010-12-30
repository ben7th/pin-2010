module MindmapApiMethods
  # 进行修改操作
  def do_operation(oper)
    option = MindmapApiOption.new(oper)
    case option.operation
    when 'do_insert' then
      _do_insert(option.params)
    when 'do_delete' then
      _do_delete(option.params)
    when 'do_title' then
      _do_title(option.params)
    when 'do_toggle' then
      _do_toggle(option.params)
    when 'do_image' then
      _do_image(option.params)
    when 'do_rm_image' then
      _do_rm_image(option.params)
    when 'do_note' then
      _do_note(option.params)
    when 'do_move' then
      _do_move(option.params)
    end
  end

  def update_or_create_note(local_id,note)
    if note!=''&&note!='<br>'
      # 创建或者更新
      update_node_note(local_id,note)
    else
      # 删除
      destroy_node_note(local_id)
    end
  end

  ########## api 用方法

  # parent 必要参数 指定一个节点的id,用来指定在哪个节点插入新节点
  # option[:index] 可选参数 指定节点插入到哪一个顺序位置，
  # 默认为0，如果传入的index大于实际的parent节点下的子节点个数，取最大值
  # option[:title] 可选参数 指定新节点的标题
  # option[:id] 可选参数 指定新节点的 id 八位随机字符串
  def _do_insert(params)
    parent_id = params.parent_id
    index = params.index
    new_node_id = params.new_node_id
    title = params.title

    _change_struct do |doc|

      parent = doc.at_css("N##{parent_id}")

      node = Nokogiri::XML::Node.new('N',doc)
      node["id"] = new_node_id
      node["t"] = title
      node["f"] = "0"

      children = parent.xpath("N")

      if _index_valid?(index,children.count)
        next_node = children[index]
        next_node.add_previous_sibling node
      else
        parent.add_child node
      end
      
      {:params_hash=>params.hash,:operation_kind=>"do_insert"}
    end
  end

  def _index_valid?(index,children_count)
    (children_count > 0) && (children_count > index) && (index != -1)
  end

  # 删除节点
  def _do_delete(params)
    node_id = params.node_id
    _change_struct do |doc|
      node_element = doc.at_css("N[id='#{node_id}']")
      node_element.remove
      {:params_hash=>params.hash,:operation_kind=>"do_delete"}
    end
  end

  # 修改节点标题
  def _do_title(params)
    node_id = params.node_id
    title = params.title
    _change_struct do |doc|
      node_element = doc.at_css("N[id='#{node_id}']")
      node_element.attribute('t').value = title
      {:params_hash=>params.hash,:operation_kind=>"do_title"}
    end
  end
  
  # 展开/折叠 一个节点
  def _do_toggle(params)
    node_id = params.node_id
    fold = params.fold

    _change_struct do |doc|
      node_element = doc.at_css("N[id='#{node_id}']")
      if fold.blank?
        fold_attr = node_element['f']
        fold_value = fold_attr.blank? ? "0" : fold_attr
        node_element['f'] = fold_value=='1' ? '0' : '1'
      else
        node_element['f'] = fold
      end
      {:params_hash=>params.hash,:operation_kind=>"do_toggle"}
    end
  end

  # 插入一个图片
  def _do_image(params)
    node_id = params.node_id
    url = params.image.url
    width = params.image.width
    height = params.image.height

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_id}']")
      node['i'] = url
      node['iw'] = width
      node['ih'] = height
      {:params_hash=>params.hash,:operation_kind=>"do_image"}
    end
  end

  # 删除一个节点上的图片
  def _do_rm_image(params)
    node_id = params.node_id
    
     _change_struct do |doc|
      node = doc.at_css("N[id='#{node_id}']")
      node.remove_attribute("i")
      node.remove_attribute("iw")
      node.remove_attribute("ih")
      {:params_hash=>params.hash,:operation_kind=>"do_rm_image"}
    end
  end

  # 移动某个节点
  def _do_move(params)
    node_id = params.node_id
    putright = params.putright
    index = params.index
    parent_id = params.parent_id

    _change_struct do |doc|
      root_note = doc.at_css("Nodes > N")
      target = doc.at_css("N[id='#{parent_id}']")
      node = doc.at_css("N[id='#{node_id}']")
      node.remove

      node['pr'] = putright
      node.remove_attribute('pr') if root_note["id"] != target["id"]

      children = target.xpath("N")

      if children.count>0 && index<children.count && index != -1
        next_node = children[index]
        next_node.add_previous_sibling node
      else
        target.add_child node
      end
      {:params_hash=>params.hash,:operation_kind=>"do_move"}
    end
  end

  # 给某个节点增加备注
  def _do_note(params)
    node_id = params.node_id
    note = params.note
    _change_struct do |doc|
      self.update_or_create_note(node_id,note)
      {:params_hash=>params.hash,:operation_kind=>"do_note"}
    end
  end

  # 修改一个节点的颜色
  def do_change_color(node_number,option)
    params_hash = option.merge({:node=>node_number})
    return false if node_number.blank?

    bgc = option[:bgc]
    fgc = option[:fgc]

    bgc.strip! if bgc
    fgc.strip! if fgc

    # 验证 bgc 和 fgc 的格式
    return false if bgc && (/^#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$/ !~ bgc)
    return false if fgc && (/^#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$/ !~ fgc)

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_number}']")
      node["bgc"] = bgc if bgc
      node["fgc"] = fgc if fgc
      {:params_hash=>params_hash,:operation_kind=>"do_change_color"}
    end
  end

  # 给一个节点增加链接
  def do_add_link(node_number,link)
    params_hash = {:node=>node_number,:link=>link}
    return false if node_number.blank?
    return false if link.blank?
    link.strip!
    return false if link !~ %r{^(https?://)[^\s<]+$}

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_number}']")
      node["link"] = link
      {:params_hash=>params_hash,:operation_kind=>"do_add_link"}
    end
  end

  # 修改一个节点的字体大小
  def do_change_font_size(node_number,size)
    params_hash = {:node=>node_number,:fs=>size}
    return false if node_number.blank?
    return false if size.blank?

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_number}']")
      node["fs"] = "#{size}"
      {:params_hash=>params_hash,:operation_kind=>"do_change_font_size"}
    end
  end

  # 修改节点文字是否为粗体字
  def do_set_font_bold(node_number,bold)
    params_hash = {:node=>node_number,:bold=>bold}
    return false if node_number.blank?
    return false if bold.blank?
    fb = "1"
    fb = "0" if bold == "false"

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_number}']")
      node["fb"] = fb
      {:params_hash=>params_hash,:operation_kind=>"do_set_font_bold"}
    end
  end

  # 修改节点文字是否为斜体字
  def do_set_font_italic(node_number,italic)
    params_hash = {:node=>node_number,:italic=>italic}
    return false if node_number.blank?
    return false if italic.blank?

    fi = "1"
    fi = "0" if italic == "false"

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_number}']")
      node["fi"] = fi
      {:params_hash=>params_hash,:operation_kind=>"do_set_font_italic"}
    end
  end

  # 保存导图结构，并保存操作历史记录
  def _change_struct(&block)
    old_struct = self.struct.clone
    doc = Nokogiri::XML(self.struct)

    params = yield doc

    current_revision = doc.at_css("Nodes")["revision"].to_i || 0
    doc.at_css("Nodes")["revision"] = (current_revision + 1).to_s
    self.struct = doc.to_s

    params_hash = params[:params_hash]
    operation_kind = params[:operation_kind]

    if self.struct!=old_struct
      self.save!
      HistoryRecord.record_operation(self,
        :struct=>old_struct,
        :kind=>operation_kind,
        :params_hash=>params_hash)
    end
    return true
  end
end