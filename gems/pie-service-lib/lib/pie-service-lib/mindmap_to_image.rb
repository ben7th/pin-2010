require 'RMagick'
require 'nokogiri'
require "ap"

class MindmapToImage

  attr_accessor :mindmap

  def mindmap
    @mindmap
  end

  attr_accessor :zoom

  attr_accessor :map_hash

  attr_accessor :fixed_width,:fixed_height 

  def initialize(mindmap)
    @mindmap = mindmap
  end

  def self.testcase(i = 0)
    arr = [
      '<Nodes maxid="28"><N id="0" t="欢迎使用\nMindPin思维导图编辑器 v0.2\n您可以在这里进行测试" f="0"><N id="1" t="在线绘制导图" f="0" pr="0"><N id="4" t="ABCDEFGH" f="0" pr="1"><N id="100" t="TESTTEST"/></N><N id="5" t="随时随地" f="0" pr="1"/><N id="22" t="管理维护方便" f="0" pr="1"/><N id="26" t="所有编辑自动保存" f="0" pr="1"/></N><N id="21" t="分支也可以在左边\n支持两侧排列" f="0" pr="0"/><N id="15" t="键盘操作" f="0" pr="1"><N id="8" t="按空格键\n编辑节点" f="0" pr="1"><N id="10" t="编辑节点时\nShift + 回车\n内容换行" f="0" pr="1"/></N><N id="9" t="Insert 键\n添加新的子节点" f="0" pr="1"/><N id="13" t="回车键\n添加相邻节点" f="0" pr="1"/><N id="27" t="方向键\n移动编辑焦点" f="0" pr="1"/></N><N id="16" t="鼠标操作" f="0" pr="1"><N id="7" t="点击鼠标右键\n触发菜单" f="0" pr="1"><N id="200" t="和谐"/></N><N id="12" t="鼠标双击\n也可以编辑节点" f="0" pr="1"/><N id="17" t="鼠标拖拽画布空白区\n移动画布" f="0" pr="1"/><N id="18" t="鼠标拖拽节点到另一节点\n改变节点位置" f="0" pr="1"/><N id="19" t="鼠标拖拽节点到空白区\n将节点变为分支" f="0" pr="1"/></N><N id="23" t="节点\n支\n持\n备\n注" f="0" pr="0"/><N id="24" t="节点支持插入图片\n从右键菜单选择" f="0" pr="0" i="http://www.mindpin.com/images/mindpin.png" iw="123" ih="30" ib="1"/></N></Nodes>',
      '<Nodes maxid="7"><N id="0" t="ROOT NODEdgdhfsghkldfjgsdlfkgjsd;lkfjglkdfsgjsd;flkgjldsfgkd;sjflgslf" f="0"><N id="1" t="JAVA" f="0" pr="1"><N id="5" t="RUBY" f="0" pr="0"/><N id="6" t="PYTHON" f="0" pr="0"/></N><N id="2" t="PHP" f="0" pr="0"><N id="3" t="C Sharp" f="0" pr="0"/><N id="4" t="DELPHI" f="0" pr="0"/></N></N></Nodes>',
      '<Nodes maxid="53"><N id="0" t="鸟类雅称" f="0"><N id="2" t=" " f="0" pr="1"><N id="3" t="爱的歌手" f="0" pr="0"><N id="4" t="东方鸽" f="0" pr="0"/></N><N id="5" t="草原歌手" f="0" pr="0"><N id="6" t="云雀" f="0" pr="0"/></N><N id="7" t="林中歌手" f="0" pr="0"><N id="8" t="画眉" f="0" pr="0"/></N><N id="9" t="鸟中歌星" f="0" pr="0"><N id="10" t="百灵鸟" f="0" pr="0"/></N><N id="11" t="黑管吹奏手" f="0" pr="0"><N id="12" t="黄鹂" f="0" pr="0"/></N><N id="13" t="口技专家" f="0" pr="0"><N id="14" t="乌鸦" f="0" pr="0"/></N></N><N id="15" t=" " f="0" pr="1"><N id="16" t="爱情之鸟" f="0" pr="0"><N id="17" t="鸳鸯" f="0" pr="0"/></N><N id="18" t="吉祥之鸟" f="0" pr="0"><N id="19" t="燕子" f="0" pr="0"/></N><N id="20" t="鸟中仙女" f="0" pr="0"><N id="21" t="天鹅" f="0" pr="0"/></N><N id="22" t="春天信使" f="0" pr="0"><N id="23" t="杜鹃" f="0" pr="0"/></N></N><N id="24" t=" " f="0" pr="1"><N id="25" t="自然界清洁工" f="0" pr="0"><N id="26" t="兀鹰" f="0" pr="0"/></N><N id="27" t="鸟中裁缝" f="0" pr="0"><N id="28" t="缝叶莺" f="0" pr="0"/></N></N><N id="43" t=" " f="0" pr="0"><N id="44" t="除蝗能手" f="0" pr="0"><N id="45" t="燕鸻" f="0" pr="0"/></N><N id="46" t="灭鼠专家" f="0" pr="0"><N id="47" t="猫头鹰" f="0" pr="0"/></N><N id="48" t="森林专家" f="0" pr="0"><N id="49" t="啄木鸟" f="0" pr="0"/></N><N id="50" t="捕鱼能手" f="0" pr="0"><N id="51" t="鸬鹚" f="0" pr="0"/></N></N><N id="38" t=" " f="0" pr="0"><N id="39" t="特种通信兵" f="0" pr="0"><N id="40" t="信鸽" f="0" pr="0"/></N><N id="41" t="忠实信使" f="0" pr="0"><N id="42" t="雁" f="0" pr="0"/></N></N><N id="29" t=" " f="0" pr="0"><N id="30" t="江湖闲客" f="0" pr="0"><N id="31" t="欧" f="0" pr="0"/></N><N id="32" t="鸟族闲客" f="0" pr="0"><N id="33" t="孔雀" f="0" pr="0"/></N><N id="34" t="空中狮虎" f="0" pr="0"><N id="35" t="鹰" f="0" pr="0"/></N><N id="36" t="动物人参" f="0" pr="0"><N id="37" t="鹌鹑" f="0" pr="0"/></N></N><N id="52" t="心智绘图书僮网www.mind-picture.com" f="0" pr="0"/></N></Nodes>',
      '<Nodes maxid="117"><N id="0" t="佛教" f="0"><N id="14" t="宗派" f="0" pr="1"><N id="1" t="显教" f="0" pr="1"><N id="48" t="中国" f="1" pr="1"><N id="9" t="华严宗" f="0" pr="1"/><N id="10" t="天台宗 法华宗" f="0" pr="1"/><N id="11" t="净土宗" f="0" pr="1"/><N id="12" t="禅宗" f="0" pr="1"><N id="15" t="北宗 渐修" f="0" pr="1"/><N id="92" t="南宗 顿悟" f="0" pr="1"><N id="93" t="马祖禅" f="0" pr="1"><N id="95" t="沩仰" f="0" pr="1"/><N id="96" t="临济" f="0" pr="1"/></N><N id="94" t="石头禅" f="0" pr="1"><N id="97" t="曹洞 " f="0" pr="1"/><N id="98" t="云门 " f="0" pr="1"/><N id="99" t="法眼 " f="0" pr="1"/></N></N></N><N id="13" t="律宗" f="0" pr="1"/><N id="77" t="法相唯识宗" f="0" pr="1"/><N id="80" t="三论宗" f="0" pr="1"/></N><N id="47" t="印度" f="0" pr="1"><N id="3" t="小乘" f="0" pr="1"><N id="81" t="上座部" f="0" pr="1"><N id="72" t="分别说部（南方上座部）" f="0" pr="1"/><N id="73" t="说一切有部" f="0" pr="1"><N id="86" t="经量部" f="0" pr="1"/></N><N id="82" t="犊子部" f="0" pr="1"><N id="83" t="正量部" f="0" pr="1"/></N></N><N id="85" t="大众部" f="0" pr="1"/></N><N id="4" t="大乘" f="0" pr="1"><N id="7" t="中观派 大乘空宗" f="0" pr="1"><N id="75" t="中观自续派" f="0" pr="1"/><N id="76" t="中观应成派" f="0" pr="1"/></N><N id="8" t="瑜伽行派 大乘有宗" f="0" pr="1"><N id="88" t="无相唯识" f="0" pr="1"/><N id="89" t="有相唯识" f="0" pr="1"/></N></N></N></N><N id="2" t="密教 金刚乘" f="0" pr="1"><N id="5" t="东密" f="0" pr="1"/><N id="6" t="藏密" f="0" pr="1"/></N></N><N id="17" t="教义" f="0" pr="1"><N id="43" t="二谛" f="1" pr="1"><N id="37" t="俗谛－缘起有－生住异灭" f="0" pr="1"/><N id="44" t="真谛－自性空－不生不灭" f="0" pr="1"/></N><N id="38" t="三法印" f="1" pr="1"><N id="39" t="诸行无常" f="0" pr="1"/><N id="40" t="诸法无我" f="0" pr="1"/><N id="41" t="涅槃寂静" f="0" pr="1"/></N><N id="27" t="四圣谛" f="1" pr="1"><N id="28" t="苦" f="0" pr="1"/><N id="29" t="集" f="0" pr="1"/><N id="30" t="灭" f="0" pr="1"/><N id="31" t="道" f="0" pr="1"/></N></N><N id="67" t="修持" f="1" pr="1"><N id="68" t="三学" f="0" pr="1"><N id="69" t="戒" f="0" pr="1"/><N id="70" t="定" f="0" pr="1"/><N id="71" t="慧" f="0" pr="1"/></N><N id="50" t="六度（六波罗蜜多）" f="0" pr="1"><N id="53" t="布施" f="0" pr="1"/><N id="54" t="持戒" f="0" pr="1"/><N id="55" t="忍辱" f="0" pr="1"/><N id="56" t="精进" f="0" pr="1"/><N id="57" t="禅定" f="0" pr="1"/><N id="58" t="般若" f="0" pr="1"/></N><N id="52" t="八正道" f="0" pr="1"><N id="59" t="正见" f="0" pr="1"/><N id="60" t="正思维（正志）" f="0" pr="1"/><N id="61" t="正语" f="0" pr="1"/><N id="62" t="正业" f="0" pr="1"/><N id="63" t="正命" f="0" pr="1"/><N id="64" t="正方便（正精进）" f="0" pr="1"/><N id="65" t="正念" f="0" pr="1"/><N id="66" t="正定" f="0" pr="1"/></N></N><N id="18" t="人物" f="1" pr="1"><N id="32" t="四大菩萨" f="0" pr="1"><N id="33" t="大智大慧 文殊菩萨  骑青狮持剑 五台山 风" f="0" pr="1"/><N id="34" t="大行大定 普贤菩萨 骑六牙白象 峨眉山 火" f="0" pr="1"/><N id="35" t="大慈大悲 观音菩萨 普陀山 水" f="0" pr="1"/><N id="36" t="大誓大愿 地藏王菩萨 九华山 地" f="0" pr="1"/></N><N id="19" t="竖三世佛" f="0" pr="1"><N id="20" t="燃灯佛 过去佛" f="0" pr="1"/><N id="21" t="释迦佛 现在佛" f="0" pr="1"/><N id="22" t="弥勒佛 未来佛" f="0" pr="1"/></N><N id="23" t="横三世佛" f="0" pr="1"><N id="24" t="西方极乐世界 阿弥陀佛 观音菩萨 大势至菩萨" f="0" pr="1"/><N id="25" t="娑婆世界 释迦佛 文殊菩萨 普贤菩萨" f="0" pr="1"/><N id="26" t="东方净琉璃世界 药师佛 日光菩萨 月光菩萨" f="0" pr="1"/></N><N id="108" t="罗汉" f="0" pr="1"><N id="109" t="舍利弗 智慧第一" f="0" pr="1"/><N id="110" t="目犍连 神通第一" f="0" pr="1"/><N id="111" t="阿难 多闻第一" f="0" pr="1"/><N id="112" t="大迦叶 苦行第一" f="0" pr="1"/><N id="113" t="大迦旃延 议论第一" f="0" pr="1"/><N id="114" t="阿那律 天眼第一" f="0" pr="1"/><N id="115" t="优婆离 持戒第一" f="0" pr="1"/><N id="116" t="须菩提 解空第一" f="0" pr="1"/></N></N></N></Nodes>'
    ]
    return self.new(arr[i])
  end

  def zoom
    @zoom || 1
  end

  def v_padding
    15 * zoom
  end

  def pointsize
    14 * zoom
  end

  def left_padding
    80 * zoom
  end
  def top_padding
    70 * zoom
  end
  
  def height_padding
    100 * zoom
  end
  def width_padding
    160 * zoom
  end

  def line_width
    1 * zoom
  end
  def border_width
    2 * zoom
  end

  def width_margin
    40 * zoom
  end

  def join_point_offset
    12 * zoom
  end

  def join_point_top_offset
    1 * zoom
  end

  def joint_point_radius
    4 * zoom
  end

  def root_join_point_offset
    8 * zoom
  end

  def root_join_point_top_offset
    10 * zoom
  end

  def root_join_point_radius
    1.5 * zoom
  end

  def bezier_x_offset
    9 * zoom
  end
  def bezier_x_offset_right
    10 * zoom
  end

  def node_inner_x_padding
    4 * zoom
  end

  def node_inner_y_padding
    2 * zoom
  end

  def root_inner_x_padding
    8 * zoom
  end

  def root_inner_y_padding
    6 * zoom
  end

  # 默认绘图对象
  def default_gc
    @default_gc ||= new_gc
  end

  def new_gc
    ps = pointsize
    Magick::Draw.new do |opts|
      opts.font = RAILS_ENV == "production" ? "/web/2010/pin-2010/yahei.ttf" : "/web1/pin-2010/yahei.ttf"
      opts.pointsize = ps
    end
  end

  # 获取文字尺寸信息
  def get_text_size(text)
    img ||= Magick::Image.new(1,1,Magick::HatchFill.new('blue','blue'))
    metrics = default_gc.get_multiline_type_metrics(img, text)
    return metrics
  end
  
  ##########################################################

  # 根据传入的xml字符串计算包括尺寸数据的 map_hash
  def get_nodes_hash(xmlstr)
    doc = Nokogiri::XML xmlstr
    node = doc.at('mindmap>node')
    get_nodes_locations(_build_node_hash(node))
  end
  
    def _build_node_hash(node)
      _build_hash_include_id_title_width_height(node).
        merge!(_get_extra_hash(node)).
        merge! :children=>node.xpath("./node").map {|child| _build_node_hash(child)}
    end

    def _build_hash_include_id_title_width_height(node)
      title = trans_xml_title(node["title"])
      metrics = get_text_size(title)
      {:id=>node["id"],:title=>title,:width=>metrics.width,:height=>metrics.height}
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

    # 转换标题
    def trans_xml_title(title)
      title.gsub(/\\./){|m| eval '"'+m+'"'}
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
    
    root[:left_c_top_off] = (max_height - left_subtrees_total_height) / 2
    root[:right_c_top_off] = (max_height - right_subtrees_total_height) / 2
    root[:y_off]=(max_height - root_height)/2
    
    root[:x] = 0
    root[:y] = root[:y_off]
    
    root[:max_height] = max_height
    
    return root
  end
  
    def locations_recursion(parent,node)

      children = node[:children]
      
      children_total_height = _get_children_total_height_of_node(node)
      subtree_width = _get_subtree_width_of_node(node)
      
      node[:subtree_width] = subtree_width
      
      self_height = node[:height]
     
      subtree_height = 0
      
      if children_total_height >= self_height
        node[:cy_off] = 0
        node[:y_off] = (children_total_height - self_height) / 2
        node[:y_off] -= v_padding / 2 if children.length > 1
        subtree_height = children_total_height + v_padding
      else
        node[:cy_off] = (self_height - children_total_height) / 2
        node[:y_off] = 0
        subtree_height = self_height
        subtree_height += v_padding if parent[:children].length > 1
      end
     
      node[:subtree_height] = subtree_height
      
      return subtree_height
    end

    def _get_children_total_height_of_node(node)
      node[:children].map { |child|
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

  ##########################
  #### 继续重构
  
  def paint_nodes(img)
    node = map_hash
    gc = default_gc

    oleft = node[:left_subtree_width] + left_padding
    
    gc.translate(oleft, top_padding)
    
    gc.fill('black')
    gc.stroke_width(line_width)
    
    left_c_top_off = node[:left_c_top_off]
    right_c_top_off = node[:right_c_top_off]
    
    x = node[:x]
    y = node[:y]
    
    title = node[:title]
    width = node[:width]
    height = node[:height]
    
    node[:children].each do |child|
      if child[:putright]
        # 右侧
        paint_recursion(node,child,right_c_top_off)
       
        # 画右侧的一级子节点连接线
        x1 = x + width/2
        y1 = y + height/2 - root_join_point_top_offset
        
        x2 = child[:x] - root_join_point_offset
        y2 = child[:y] + child[:height]/2 - v_padding
        
        gc.stroke('#5a5a5a')
        gc.line(x1,y1,x2,y2)
        gc.fill('black')
        gc.ellipse(x2+root_join_point_radius,y2,root_join_point_radius,root_join_point_radius,0,360)
        
        right_c_top_off += child[:subtree_height]
      else
        # 左侧
        paint_recursion(node,child,left_c_top_off)
        
        # 画左侧的一级子节点连接线
        x1 = x + width/2
        y1 = y + height/2 - root_join_point_top_offset
        
        x2 = child[:x] + child[:width] + root_join_point_offset
        y2 = child[:y] + child[:height]/2 - v_padding
        
        gc.stroke('#5a5a5a')
        gc.line(x1,y1,x2,y2)
        gc.fill('black')
        gc.ellipse(x2-root_join_point_radius,y2,root_join_point_radius,root_join_point_radius,0,360)
        
        left_c_top_off += child[:subtree_height]
      end
    end
    
    # 画根结点
    
    gc.stroke('#77AAFF')
    gc.stroke_width(border_width)
    gc.fill('#E9F0FF')

    gc.roundrectangle(x-root_inner_x_padding,y-pointsize-root_inner_y_padding,
      x+width+root_inner_x_padding,y-pointsize+height+root_inner_y_padding,
      root_inner_x_padding,root_inner_y_padding)
    
    gc.stroke_width(line_width)
    gc.stroke('transparent')
    gc.fill('black')
    gc.text(x,y,title)
    
    gc.draw(img)
  end
  
    def paint_recursion(parent,node,top_off)
      
      parent_x = parent[:x]
      parent_real_y = parent[:y]-parent[:y_off]
      parent_width = parent[:width]
      parent_cy_off = parent[:cy_off]
      
      y_off = node[:y_off]

      title = node[:title]
      width = node[:width]
      height = node[:height]
      
      x = node[:x] = parent_x + parent_width + width_margin
      y = node[:y] = parent_real_y + parent_cy_off + top_off + y_off
      
      unless node[:putright]
        x = node[:x] = parent_x - width - width_margin
      end
      
      gc = default_gc

      gc.stroke('transparent')
      gc.fill('black')
      gc.text(x,y,title)
      
      gc.stroke('#999999')
      gc.fill('transparent')

      gc.roundrectangle(x-node_inner_x_padding, y-pointsize-node_inner_y_padding,
        x+width+node_inner_x_padding, y-pointsize+height+node_inner_y_padding,
        node_inner_x_padding, node_inner_y_padding)
      
      if node[:children].length > 0
        # 绘制连接点
        r_x = x + width + join_point_offset
        unless node[:putright]
          r_x = x - join_point_offset
        end

        r_y = y + height/2 - v_padding + join_point_top_offset

        c_top_off = 0
        node[:children].each do |child|
          paint_recursion(node,child,c_top_off)

          # 遍历过程中绘制连接线
          x1 = r_x + bezier_x_offset
          x2 = x + width + width_margin - joint_point_radius

          gc.stroke('#5a5a5a')
          unless node[:putright]
            x1 = r_x - bezier_x_offset_right
            x2 = x - width_margin + joint_point_radius
            gc.line(r_x + joint_point_radius*2, r_y, x1, r_y)
          else
            gc.line(r_x - joint_point_radius*2, r_y, x1, r_y)
          end

          y1 = r_y
          y2 = y - y_off + node[:cy_off] + c_top_off + child[:y_off] - pointsize + child[:height]/2

          c_top_off += child[:subtree_height]

          gc.stroke('#5a5a5a')
          gc.fill('transparent')
          gc.bezier(x1,y1,x1,y2,x1,y2,x2,y2)
        end
     
        gc.stroke('black')
        gc.fill('#999999')
        gc.ellipse(r_x, r_y, joint_point_radius, joint_point_radius, 0, 360)
      end
      
    end
  
  def paint_sign(image,w,h)
    gc0 = new_gc
    
    gc0.stroke('#3274D0')
    gc0.fill('#3274D0')

    gc0.rectangle(0,h-30,w,h)

    sign_height = 30 * zoom
    gc0.rectangle(0,0,w-1,sign_height)

    logo_tail_path = "#{File.dirname(__FILE__)}/images/logo_tail.png"
    logo = Magick::ImageList.new(logo_tail_path)

    gc0.composite(w-120,h-30,0,0,logo)
    
    gc0.stroke('black')
    gc0.fill('transparent')
    gc0.rectangle(0,0,w-1,h-1)
    
    gc0.stroke('transparent')
    gc0.fill('white')
    gc0.pointsize=16
    gc0.text(10,h-10,"http://www.mindpin.com")

    gc1 = new_gc
    gc1.stroke('transparent')
    gc1.fill('white')
    gc1.text(10*zoom,20*zoom,mindmap.title)
    gc1.text(get_text_size(mindmap.title).width+sign_height,20*zoom,_author_name)
    
    gc0.draw(image)
    gc1.draw(image)
  end


  def export(size_param)
    param = size_param.to_s

    @map_hash = get_nodes_hash(mindmap.struct)


    if param.include?('x')
      @fixed_width , @fixed_height = param.split('x').map{|x| x.to_i}
      return write_to_file(export_fixed)
    end

    @zoom = param.to_f
    return write_to_file(export_zoom)
  end

  def export_fixed
    # 6.25 对于尺寸放大的图片，要做到清晰，目前没有比较好的方法，仍需修改
    @zoom = 1
    img = export_zoom
    image_width = _width_of_image
    image_height = _height_of_image
    if image_width > image_height
      width = @fixed_width
      height = image_height * @fixed_width / image_width
      img.resize(width,height)
    else
      width = image_width * @fixed_height / image_height
      height = @fixed_height
      img.resize(width,height)
    end
  end

  def export_zoom

    image_width = _width_of_image
    image_height = _height_of_image

    img = Magick::Image.new(image_width, image_height, Magick::HatchFill.new('white','white'))

    paint_nodes(img)
    paint_sign(img, image_width, image_height)

    return img
  end

  def _height_of_image
    _height_of_mindmap.round
  end

  def _height_of_mindmap
    map_hash[:max_height] + height_padding
  end

  def _width_of_image
    [_width_of_mindmap, _width_min, _width_of_sign].max.round
  end

  def _width_of_mindmap
    map_hash[:left_subtree_width] + map_hash[:width] + map_hash[:right_subtree_width] + width_padding
  end

  def _width_min
    200 + 50 + 120
  end

  def _width_of_sign
    get_text_size(mindmap.title).width +
    width_margin +
    get_text_size(_author_name).width
  end

  def _author_name
    " "
  end

  def write_to_file(img)
    file_path = "/tmp/#{randstr}.png"
    img.write(file_path)
    return file_path
  end

  def randstr(length=8)
    base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    size = base.size
    re = ''<<base[rand(size-10)]
    (length-1).times  do
      re<<base[rand(size)]
    end
    re
  end
  
end