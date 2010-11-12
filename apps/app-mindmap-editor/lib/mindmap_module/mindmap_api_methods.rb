module MindmapApiMethods
  ########## api 用方法

  # parent 必要参数 用来指定当前在哪个节点插入新节点
  # option[:index] 可选参数 指定节点插入到哪一个顺序位置，
  # 默认为0，如果传入的index大于实际的parent节点下的子节点个数，取最大值
  # option[:index] 可选参数 指定新节点的标题
  def do_insert(parent,option)
    return false if !parent
    params_hash = option.merge({:parent=>parent})
    index = option[:index] || -1
    index = index.to_i
    title = option[:title] || "NewSubNode"

    _change_struct do |doc|
      root = doc.at_css("Nodes")

      parent = doc.at_css("N##{parent}")

      new_node_id = root['maxid'].to_i

      node = Nokogiri::XML::Node.new('N',doc)
      node["id"] = "#{new_node_id}"
      node["t"] = title
      node["f"] = "#{0}"

      root['maxid'] = "#{new_node_id + 1}"

      children = parent.css("N")

      if children.count>0 && index < children.count && index != -1
        next_node = children[index]
        next_node.add_previous_sibling node
      else
        parent.add_child node
      end
      {:params_hash=>params_hash,:operation_kind=>"do_insert"}
    end
  end

  # 删除节点
  def do_delete(node)
    params_hash = {:node=>node}
    _change_struct do |doc|
      node_element = doc.at_css("N[id='#{node}']")
      return false if node_element.blank?
      node_element.remove
      {:params_hash=>params_hash,:operation_kind=>"do_delete"}
    end
  end

  # 修改节点标题
  def do_title(node,title)
    params_hash = {:node=>node,:title=>title}
    _change_struct do |doc|
      node_element = doc.at_css("N[id='#{node}']")
      return false if node_element.blank?
      node_element.attribute('t').value = title
      {:params_hash=>params_hash,:operation_kind=>"do_title"}
    end
  end

  # 插入一个图片
  def do_image(node_number,url,option)
    params_hash = option.merge({:url=>url,:node=>node_number})
    return false if node_number.blank?
    return false if url.blank?

    _change_struct do |doc|
      node = doc.at_css("N[id='#{node_number}']")
      node['i'] = url
      node['iw'] = option[:width] || ""
      node['ih'] = option[:height] || ""
      {:params_hash=>params_hash,:operation_kind=>"do_image"}
    end
  end

  # 展开/折叠 一个节点
  def do_toggle(node,fold=nil)
    params_hash = {:node=>node,:fold=>fold}
    _change_struct do |doc|
      node_element = doc.at_css("N[id='#{node}']")
      return false if node_element.blank?
      fold_attr = node_element['f']
      fold_value = fold_attr.blank? ? "0" : fold_attr
      if fold.blank?
        node_element['f'] = '0' if fold_value.blank?
        node_element['f'] = fold_value=='1' ? '0' : '1'
      else
        node_element['f'] = fold=='true'? '1' : '0'
      end
      {:params_hash=>params_hash,:operation_kind=>"do_toggle"}
    end
  end

  # 移动某个节点
  def do_move(node_number,target_number,option)
    params_hash = option.merge({:node=>node_number,:target=>target_number})

    puton = option[:puton] || "1"
    puton = "0" if option[:puton] == "left"
    puton = "1" if option[:puton] == "right"

    _change_struct do |doc|
      target = doc.at_css("N[id='#{target_number}']")
      node = doc.at_css("N[id='#{node_number}']")
      node.remove

      node['pr'] = puton if target_number.to_i == 0
      node.remove_attribute('pr') if target_number.to_i != 0

      idx = option[:index] || -1
      idx = idx.to_i

      children = target.css("N")

      if children.count>0 && idx<children.count && idx != -1
        next_node = children[idx]
        next_node.add_previous_sibling node
      else
        target.add_child node
      end
      {:params_hash=>params_hash,:operation_kind=>"do_move"}
    end
  end

  # 给某个节点增加备注
  def do_note(node,note)
    params_hash = {:node=>node,:note=>note}

    self.update_or_create_note(node,note)
    HistoryRecord.record_operation(self,
      :struct=>self.struct,
      :kind=>"do_note",
      :params_hash=>params_hash)
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

  def _change_struct(&block)
    old_struct = self.struct.clone
    doc = Nokogiri::XML(self.struct)

    params = yield doc

    params_hash = params[:params_hash]
    operation_kind = params[:operation_kind]

    self.struct = doc.to_s
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