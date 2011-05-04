class MindmapOperate
  def initialize(mindmap,oper,operator)
    @mindmap = mindmap
    @option = MindmapApiOption.new(oper)
    @operation = @option.operation
    @params = @option.params
    @operator = operator
  end

  # 进行修改操作
  def do_operation
    case @operation
    when 'do_insert' then
      _do_insert
    when 'do_delete' then
      _do_delete
    when 'do_title' then
      _do_title
    when 'do_toggle' then
      _do_toggle
    when 'do_image' then
      _do_image
    when 'do_rm_image' then
      _do_rm_image
    when 'do_note' then
      _do_note
    when 'do_move' then
      _do_move
    end
  end

  # parent 必要参数 指定一个节点的id,用来指定在哪个节点插入新节点
  # option[:index] 可选参数 指定节点插入到哪一个顺序位置，
  # 默认为0，如果传入的index大于实际的parent节点下的子节点个数，取最大值
  # option[:title] 可选参数 指定新节点的标题
  # option[:id] 可选参数 指定新节点的 id 八位随机字符串
  def _do_insert
    parent_id = @params.parent_id
    index = @params.index
    new_node_id = @params.new_node_id
    title = @params.title

    _change_struct do |doc|
      parent = doc.node(parent_id)
      node = doc.create_node(new_node_id,title)
      parent.insert_node(node,index)
      node.modified = @operator

      {:params_hash=>@params.hash,:operation_kind=>"do_insert",:operator=>@operator}
    end
  end

  # 删除节点
  def _do_delete
    node_id = @params.node_id
    _change_struct do |doc|
      node = doc.node(node_id)
      node.remove
      {:params_hash=>@params.hash,:operation_kind=>"do_delete",:operator=>@operator}
    end
  end

  # 修改节点标题
  def _do_title
    node_id = @params.node_id
    title = @params.title
    _change_struct do |doc|
      node = doc.node(node_id)
      node.title = title
      node.modified = @operator
      {:params_hash=>@params.hash,:operation_kind=>"do_title",:operator=>@operator}
    end
  end

  # 展开/折叠 一个节点
  def _do_toggle
    node_id = @params.node_id
    closed = @params.closed

    old_struct = @mindmap.struct.clone

    doc = MindmapDocument.new(@mindmap)
    node = doc.node(node_id)

    if closed.nil?
      node.closed = !node.closed
    else
      node.closed = closed
    end

    @mindmap.struct = doc.struct

    if @mindmap.struct!=old_struct
      @mindmap.save!
    end
    return true
  end

  # 插入一个图片
  def _do_image
    node_id = @params.node_id
    url = @params.image.url
    width = @params.image.width
    height = @params.image.height

    _change_struct do |doc|
      node = doc.node(node_id)
      node.image.url = url
      node.image.width = width
      node.image.height = height
      node.modified = @operator
      {:params_hash=>@params.hash,:operation_kind=>"do_image",:operator=>@operator}
    end
  end

  # 删除一个节点上的图片
  def _do_rm_image
    node_id = @params.node_id

    _change_struct do |doc|
      node = doc.node(node_id)
      node.image.remove
      node.modified = @operator
      {:params_hash=>@params.hash,:operation_kind=>"do_rm_image",:operator=>@operator}
    end
  end

  # 给某个节点增加备注
  def _do_note
    node_id = @params.node_id
    note = @params.note
    _change_struct do |doc|
      node = doc.node(node_id)
      node.note = note
      node.modified = @operator
      {:params_hash=>@params.hash,:operation_kind=>"do_note",:operator=>@operator}
    end
  end

  # 移动某个节点
  def _do_move
    node_id = @params.node_id
    pos = @params.pos
    index = @params.index
    parent_id = @params.parent_id

    _change_struct do |doc|
      target = doc.node(parent_id)
      node = doc.node(node_id)
      node.remove

      target.insert_node(node,index)
      node.pos = pos
      node.modified = @operator

      {:params_hash=>@params.hash,:operation_kind=>"do_move",:operator=>@operator}
    end
  end

  # 修改一个节点的颜色
  def do_change_color
    # TODO
  end

  # 给一个节点增加链接
  def do_add_link
    # TODO
  end

  # 修改一个节点的字体大小
  def do_change_font_size
    # TODO
  end

  # 修改节点文字是否为粗体字
  def do_set_font_bold
    # TODO
  end

  # 修改节点文字是否为斜体字
  def do_set_font_italic
    # TODO
  end

  # 保存导图结构，并保存操作历史记录
  def _change_struct(&block)
    old_struct = @mindmap.struct.clone
    doc = MindmapDocument.new(@mindmap)
    
    params = yield doc

    current_revision = doc.revision
    doc.revision = current_revision + 1
    doc.modified = @operator
    @mindmap.struct = doc.struct

    params_hash = params[:params_hash]
    operation_kind = params[:operation_kind]
    operator = params[:operator]

    if @mindmap.struct!=old_struct
      begin
        @mindmap.save!
      rescue Exception => ex
        p "~~~mindmap.save error~~~~~"
        p ex.class
        p ex.message
        p "~~~mindmap.save error~~~~~"
        puts ex.backtrace.join("\n")
        raise MindmapOperate::MindmapNotSaveError,"mindmap 数据库记录保存出错"
      end

      HistoryRecord.record_operation(@mindmap,
        :kind=>operation_kind,
        :params_hash=>params_hash,
        :operator=>operator)
    end
    return true
  end

  class ErrorCode
    UNKNOWN = "0"
    NODE_NOT_EXIST = "1"
    MINDMAP_NOT_SAVE = "2"
  end

  class NodeNotExistError < StandardError;end
  class MindmapNotSaveError < StandardError;end
end
