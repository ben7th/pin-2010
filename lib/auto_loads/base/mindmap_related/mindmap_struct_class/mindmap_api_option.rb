class MindmapApiOption

#{"op"=>"do_title", "node"=>"dkhJoFru", "map"=>"192", "params"=>{"title"=>"根\345\205\253"}}
#{"op"=>"do_insert", "node"=>"wNeJEj4p", "map"=>"192", "params"=>{"parent"=>"0", "index"=>8}}
#{"op"=>"do_title", "node"=>"wNeJEj4p", "map"=>"192", "params"=>{"title"=>"根\344\271\235"}}
#{"op"=>"do_move", "node"=>"wNeJEj4p", "map"=>"192", "params"=>{"parent"=>"0", "putright"=>"0", "index"=>0}}
#{"op"=>"do_move", "node"=>"dkhJoFru", "map"=>"192", "params"=>{"parent"=>"0", "putright"=>"0", "index"=>0}}
#{"op"=>"do_insert", "node"=>"CVk7oybA", "map"=>"192", "params"=>{"parent"=>"3", "index"=>3}}
#{"op"=>"do_title", "node"=>"CVk7oybA", "map"=>"192", "params"=>{"title"=>"三\345\233\233"}}
#{"op"=>"do_move", "node"=>"CVk7oybA", "map"=>"192", "params"=>{"parent"=>"3", "putright"=>"1", "index"=>1}}
#{"op"=>"do_move", "node"=>"3", "map"=>"192", "params"=>{"parent"=>"0", "putright"=>"1", "index"=>4}}

  def initialize(oper_hash)
    @oper = oper_hash
    @operation = @oper["op"]
    @params = OptionParams.new(@oper["params"])
    raise 'operation 未指定' if @operation.blank?
  end

  # 操作类型
  def operation
    @operation
  end

  # 操作的附加参数 参考/doc 下文档
  def params
    @params
  end


  class OptionParams
    def initialize(params_hash)
      @params = params_hash
    end

    def hash
      @params
    end

    # 父节点ID
    def parent_id
      _parent_id = @params["parent_id"]
      raise '父节点ID 未指定' if _parent_id.blank?
      return _parent_id
    end

    # 节点所在兄弟数组的下标，从0开始 -1 表示未指定
    def index
      _index = @params["index"]
      _index = -1 if _index.blank?
      return _index.to_i
    end

    def new_node_id
      _new_node_id = @params["new_node_id"]
      raise '节点ID 不合法; new_node_id invalid' if !_new_node_id.match /^[a-zA-z0-9]{8}$/
      _new_node_id = randstr(8) if _new_node_id.blank?
      return _new_node_id
    end

    def title
      _title = @params["title"]
      _title = "NewSubNode" if _title.nil?
      return _title
    end

    def node_id
      _node_id = @params["node_id"]
      raise '节点ID 未指定' if _node_id.blank?
      return _node_id
    end

    def closed
      _closed = @params["closed"]
      if _closed.blank?
        _closed = nil
      else
        raise "节点展开/关闭状态 #{_closed} 值指定错误，不是 true 或者 false" if ![true,false].include?(_closed)
      end
      return _closed
    end

    def img_attach_id
      _img_attach_id = @params["img_attach_id"]
      raise '图片附件ID 未指定' if _img_attach_id.blank?
      
      image_attachment = ImageAttachment.find_by_id(_img_attach_id.to_i)
      raise '没有找到图片附件对象' if image_attachment.blank?
      
      return _img_attach_id
    end

    def img_size
      _img_size = @params["img_size"]
      if _img_size!='full' && _img_size!='thumb'
        _img_size = ''
      end
      return _img_size
    end

    def bgcolor
      _bgcolor = @params["bgcolor"]
      raise '节点背景色 未指定' if _bgcolor.blank?
      return _bgcolor
    end

    def textcolor
      _textcolor = @params["textcolor"]
      raise '文字颜色 未指定' if _textcolor.blank?
      return _textcolor
    end

    def note
      _note = @params['note']
      return _note
    end

    def pos
      _pos = @params['pos']
      if _pos.blank?
        _pos = "right"
      else
        raise "节点放置侧状态 #{_pos} 值指定错误，不是 right 或者 left" if !["right","left"].include?(_pos)
      end
      return _pos
    end

#    class MapParamsImage
#      def initialize(image_hash)
#        @image = image_hash
#      end
#
#      def url
#        _url = @image['url']
#        raise '图片URL 未指定' if _url.blank?
#        return _url
#      end
#
#      def width
#        _width = @image["width"]
#        _width = nil if _width.blank?
#        return _width
#      end
#
#      def height
#        _height = @image["height"]
#        _height = nil if _height.blank?
#        return _height
#      end
#    end
  end
end
