class MindmapsController < ApplicationController
  before_filter :login_required,:only => [:mine]
  skip_before_filter :verify_authenticity_token

  # GET /mindmaps
  include MindmapFindingMethods
  def index
    @user = User.find(params[:user_id]) if params[:user_id]
    @mindmaps = get_mindmaps(params[:user_id])
  end

  def new
    @mindmap = Mindmap.new
    set_tabs_path('')
  end

  def import
    @mindmap = Mindmap.new
  end

  def show
    @mindmap = Mindmap.find(params[:id])
    respond_to do |format|
      format.html do
        if has_edit_rights?(@mindmap,current_user) && params[:sure]!='1'
          redirect_to :action=>'edit'
        else
          if @mindmap.private
            # 私有导图检查权限
            return (render :text=>'这个思维导图是私有的，您没有权限查看')
          end
          @comments=@mindmap.comments.paginate :page=>params[:page],:per_page=>10
          (@mindmap.visit_counter ||= VisitCounter.new).rise
          return (render :layout=>"mindmap",:template=>'mindmaps/viewer_v03')
        end
      end
      
      format.xml do
        if @mindmap.private && @mindmap.user_id!=current_user.id
          # 私有导图检查权限
          return (render :text=>'<code>private</code>')
        end
        render :text=>@mindmap.struct
      end

      format.mm do
        if @mindmap.private && @mindmap.user_id!=current_user.id
          # 私有导图检查权限
          return (render :text=>'<code>private</code>')
        end
        v = params[:v] || "9"
        onto = FreemindParser.export(@mindmap,v)
        send_data(onto,
          :disposition => 'attachment',
          :filename =>"#{@mindmap.title.utf8_to_gbk}_v0.#{v}.mm")
      end
      
      format.js do
        if @mindmap.private && @mindmap.user_id!=current_user.id
          # 私有导图检查权限
          return (render :text=>'private')
        end
        render :text=>@mindmap.struct_json
      end
      
      format.json do
        render :json=>{'mindmap'=>{'title'=>@mindmap.title,'logo'=>@mindmap.logo_url_for_core,'created_at'=>@mindmap.created_at}}
      end

      format.mmap do
        if @mindmap.private && @mindmap.user_id!=current_user.id
          # 私有导图
          return (render :text=>'他人的私有导图，无法下载')
        end
        path = @mindmap.export_to_mindmanager
        send_file path,:type=>"*/*",:disposition=>'attachment',:filename=>"#{@mindmap.title.utf8_to_gbk}.mmap"
      end

      format.doc do
        if @mindmap.private && @mindmap.user_id!=current_user.id
          # 私有导图
          return (render :text=>'他人的私有导图，无法下载')
        end
        path = WordXmlParser.export(@mindmap)
        send_file path,:type=>"*/*",:disposition=>'attachment',:filename=>"#{@mindmap.title.utf8_to_gbk}.doc"
      end

      # 以下为导出图片
      format.png do
        show_image('png')
      end
      format.jpg do
        show_image('jpeg')
      end
      format.gif do
        show_image('gif')
      end
    end
  end

  def show_image(format)
    if @mindmap.private && @mindmap.user_id!=current_user.id
      return(redirect_to '/images/private_quote_notice.png')
    end
    zoom = params[:zoom].blank? ? 1 : params[:zoom].to_f
    redirect_to "#{IMAGE_CACHE_SITE}/images/#{params[:id]}.#{format}?size_param=#{zoom}"
  end

  def edit
    @mindmap = Mindmap.find(params[:id])
    if has_edit_rights?(@mindmap,current_user)
      return render :layout=>"mindmap",:template=>'mindmaps/editor_v03'
    end
    redirect_to :action=>'show',:format=>'html'
  end

  def create
    @mindmap = Mindmap.create_by_params(current_user,params[:mindmap])
    if @mindmap
      if !current_user
        add_nobody_mindmap_to_cookies(@mindmap)
      end
#      @mindmap.to_share if params[:share]
       return redirect_to edit_mindmap_path(@mindmap)
    end
    @mindmap = Mindmap.new
    if params[:import] == "true"
      render :action=> :import
    else
      render :action=> :new
    end
  end

  def update
    @mindmap = Mindmap.find(params[:id])
    if has_edit_rights?(@mindmap,current_user)
        @mindmap.update_attributes!(params[:mindmap])
        if params[:fbox] == "true"
          responds_to_parent do
            render_ui do |ui|
              ui.mplist(:update,@mindmap,:partial=>"mindmaps/list/info_mindmap").fbox(:close)
            end
          end
          return
        end
        return redirect_to user_mindmaps_path(current_user)
    else
      render :text=>'没有权限',:status=>401
    end
  end
  
  def paramsedit
    @mindmap = Mindmap.find(params[:id])
    if has_edit_rights?(@mindmap,current_user)
      if request.xhr?
      return render_ui.fbox :show,:title=>"编辑信息",:partial=>"mindmaps/edit/box_params_edit",:locals=>{:mindmap=>@mindmap}
      end
      return render :template=>"mindmaps/paramsedit"
    end
  end

  # DELETE /mindmaps/1
  def destroy
    respond_to do |format|
      format.html do
        @mindmap = Mindmap.find(params[:id])
        if(@mindmap.user_id == current_user.id)
          @mindmap = Mindmap.find(params[:id])
          @mindmap.destroy
          return render_ui.mplist :remove,@mindmap
        else
          render :text=>'没有删除权限',:status=>500
        end
      end
      format.xml do
        @mindmap = Mindmap.find(params[:id])
        @mindmap.destroy
        head :ok
      end
    end
  end
  
  def setnote
    @mindmap=current_user.mindmaps.find(params[:id])
    if @mindmap.update_or_create_note(params[:local_id],params[:note])
      render :text=>'ok'
    end
  end
  
  def quote
    @mindmap = Mindmap.find(params[:id])
    @pagetitle = "获取导图引用和另存 - #{@mindmap.title}"
    
    if @mindmap.private && @mindmap.user_id!=current_user.id
      # 私有导图检查权限
      return (render :text=>'这个思维导图是私有的，您没有权限操作')
    else
      render :template => 'mindmaps/quote/quote'
    end
  end
  
  def rate
    @mindmap = Mindmap.find(params[:id])
    if !@mindmap.rated_by?(current_user) && @mindmap.user_id!=current_user.id
      stars=params[:stars].to_i
      @mindmap.rate(stars>5 ? 5:stars, current_user)
      render :text=>''
    end
  end
  
  def widget
    # 在其他页面显示widget用
    @mindmap = Mindmap.find(params[:id])
    respond_to do |format|
      format.html do
        if @mindmap.private
          # 私有导图检查权限
          return (render :text=>'这个思维导图是私有的，您没有权限查看')
        else
          render :layout=>false,:template=>'mindmaps/quote/widget'
        end
      end
      format.js do
        @width = params[:w].blank? ? 500 : params[:w].to_i
        @height = params[:h].blank? ? 400 : params[:h].to_i
        render :layout=>false,:template=>'mindmaps/quote/widget'
      end
    end
  end

  # 显示树状列表
  def outline
    @mindmap = Mindmap.find(params[:id])
  end

  # 导出向导页面
  def export
    @mindmap = Mindmap.find(params[:id])
    render_ui.fbox :show,:title=>"导出导图",:partial=>'mindmaps/edit/box_export',:locals=>{:mindmap=>@mindmap}
  end

  def clone_form
    @mindmap = Mindmap.find(params[:id])
    render_ui.fbox :show,:title=>"克隆导图",:partial=>'mindmaps/edit/box_clone',:locals=>{:mindmap=>@mindmap}
  end

  # 克隆
  def clone
    @mindmap = Mindmap.find(params[:id])
    clone_m = @mindmap.mindmap_clone(current_user,params[:mindmap])
    render_ui.mplist(:insert,[current_user,clone_m],:partial=>"mindmaps/list/info_mindmap",:locals=>{:mindmap=>clone_m},:prev=>"TOP").fbox(:close)
  end

  def convert_bundle
    @mindmap = Mindmap.find(params[:id])

    require 'digest/sha1'
    service_token = Digest::SHA1.hexdigest("#{current_user.id}#{SERVICE_KEY}")
    res = Net::HTTP.post_form URI.parse(File.join(DISCUSSION_SITE,'/documents/mindmaps')),
      :mindmap=>@mindmap.struct,:workspace_id=>params[:workspace_id],:req_user_id=>current_user.id,:service_token=>service_token

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      redirect_to [current_user,:mindmaps]
    else
      render :text=>"error",:status=>500
    end
  end

end
