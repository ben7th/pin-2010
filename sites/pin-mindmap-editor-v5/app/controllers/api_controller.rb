class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :mindmap_private_authenticate,:only=>[:show,:export,:image]

  before_filter :authenticate,:only=>[:current_user_maps,:create]

  before_filter :mindmap_creator_authenticate,
    :only=>[:do_insert,:do_delete,:do_title,
    :do_toggle,:do_image,:do_move,:do_note,
    :destroy,:do_add_link,:do_change_color,
    :do_change_font_size,:do_set_font_bold,:do_set_font_italic
  ]

  def current_user_maps
    user_id = current_user.id
    _index_maps(user_id)
  end

  def user_maps
    user_id = params[:id]
    _index_maps(user_id)
  end

  def _index_maps(user_id)
    params[:format] ||= "xml"
    params[:page] ||= 1
    params[:count] ||= 20
    maps = Mindmap.find_all_by_user_id(user_id).paginate(:page=>params[:page],:per_page=>params[:count])

    respond_to do |format|
      format.xml do
        render :xml=>maps.to_xml
      end

      format.json do
        render :json=>maps.to_json
      end
    end
  end

  def show
    params[:format] ||= "xml"

    respond_to do |format|
      format.xml do
        render :xml=>@mindmap.to_xml
      end

      format.json do
        render :json=>@mindmap.to_json
      end
    end
  end

  def export
    params[:format] ||= "mm"

    respond_to do |format|
      format.mmap do
        path = @mindmap.xml_mindpin_to_mindmap
        send_file path,:type=>"*/*",:disposition=>'attachment'
      end

      format.mm do
        onto = Tempfile.new(randstr)
        onto << @mindmap.to_freemind(params[:v])
        onto.close
        send_file(onto.path,
          :disposition => 'attachment',
          :filename =>"#{@mindmap.title}_v0.#{params[:v]||9}.mm")
      end
    end
  end

  def image
    params[:format] ||= "jpg"

    respond_to do |format|
      format.png do
        _show_image('png')
      end
      format.jpg do
        _show_image('jpeg')
      end
      format.gif do
        _show_image('gif')
      end
    end
  end

  def _show_image(format)
    if @mindmap.private && @mindmap.user_id!=current_user.id
      return(redirect_to '/images/private_quote_notice.png')
    end
    zoom = params[:zoom].blank? ? 1 : params[:zoom].to_f
    canvas = paint(@mindmap,zoom)
    img = canvas.to_blob{ self.format = format}
    send_data img, :type => "image/#{format}", :disposition => 'inline'
  end

  def do_insert
    if @mindmap.do_insert(params[:parent],:title=>params[:title],:index=>params[:index])
      return success_render
    end
    render :text=>500,:status=>500
  end


  # 删除某一个节点
  def do_delete
    return :status=>500,:text=>500 if params[:node] == "0"
    if @mindmap.do_delete(params[:node])
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 修改某个节点的title
  def do_title
    if @mindmap.do_title(params[:node],params[:title])
      return success_render
    end
    render :status=>500,:text=>500
  end

  def do_toggle
    if @mindmap.do_toggle(params[:node],params[:fold])
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 给某个节点插入一个图片
  def do_image
    if @mindmap.do_image(params[:node],params[:url],:width=>params[:width],:height=>params[:height])
      return success_render
    end
    render :text=>500,:status=>500
  end

  # 移动某个节点
  def do_move
    if @mindmap.do_move(params[:node],params[:target],:index=>params[:index],:puton=>params[:puton])
      return success_render
    end
    render :text=>500,:status=>500
  end

  # 给某个节点增加备注
  def do_note
    if @mindmap.do_note(params[:node],params[:note])
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 修改一个节点的颜色
  def do_change_color
    if @mindmap.do_change_color(params[:node],:bgc=>params[:bgc],:fgc=>params[:fgc])
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 给一个节点增加链接
  def do_add_link
    if @mindmap.do_add_link(params[:node],params[:link])
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 修改一个节点的字体大小
  def do_change_font_size
    if @mindmap.do_change_font_size(params[:node],params[:fs])
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 修改节点文字是否为粗体字
  def do_set_font_bold
    if @mindmap.do_set_font_bold(params[:node],params[:bold])
      return success_render
    end
    render :status=>500,:text=>500
  end
  
  # 修改节点文字是否为斜体字
  def do_set_font_italic
    if @mindmap.do_set_font_italic(params[:node],params[:italic])
      return success_render
    end
    render :status=>500,:text=>500
  end
  
  # 创建一个导图
  def create
    private = params[:private].blank? ? false : params[:private]
    @mindmap = Mindmap.new(:title=>params[:title],:private=>private)
    @mindmap.user = current_user
    if @mindmap.save
      @mindmap.save_on_default
      return success_render
    end
    render :status=>500,:text=>500
  end

  # 删除一个导图
  def destroy
    if @mindmap.destroy
      return success_render
    end
    return render :status=>500,:text=>500
  end

  def success_render
    respond_to do |format|
      format.xml do
        render :xml=>"<status>OK</status>"
      end
      format.json do
        render :json=>{:status=>'OK'}.to_json
      end
    end
  end
  
  def mindmap_private_authenticate
    @mindmap = Mindmap.find(params[:id])
    if @mindmap.private
      authenticate
      if current_user && (@mindmap.user_id != current_user.id)
        return render :status=>403,:text=>"403"
      end
    end
  end

  def mindmap_creator_authenticate
    @mindmap = Mindmap.find(params[:id])
    authenticate
    if current_user && (@mindmap.user_id != current_user.id)
      return render :status=>403,:text=>"403"
    end
  end

  def authenticate
    if !logged_in?
      render :status=>401,:text=>"401 Not Authorized"
    end
  end
end