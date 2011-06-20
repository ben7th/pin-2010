class TagsController < ApplicationController
  before_filter :login_required,:only=>[:fav,:unfav,:upload_logo,:logo]
  before_filter :per_load
  def per_load
    if params[:id]
      @tag = Tag.get_tag_by_full_name(params[:id])
      redirect_to "/tags/#{@tag.full_name}"  if @tag.full_name != params[:id]
      render_status_page(404,"标签没有找到") if @tag.blank?
    end
  end

  def show
    @feeds = @tag.feeds.normal.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def upload_logo
  end

  def logo
    if @tag.update_attribute(:logo,params[:logo])
      redirect_to :action=>:show
    else
      flash[:error] = "修改失败"
      redirect_to :action=>:upload_logo
    end
  end

  def detail
    if @tag.update_attribute(:detail,params[:detail])
      render :text=>"描述保存成功"
    else
      render :text=>"描述保存失败",:status=>401
    end
  end

  
  def fav
    current_user.do_fav(@tag)
    render :stats=>200,:text=>"关注成功"
  end

  def unfav
    current_user.do_unfav(@tag)
    render :stats=>200,:text=>"取消关注成功"
  end

  def index
    case params[:tab]
    when "hot"
      _index_tab_hot
    when "recently_used"
      _index_tab_recently_used
    when "another_name"
      _index_tab_another_name
    else
      _index_tab_cookies
    end
  end

  def _index_tab_cookies
    case cookies[:menu_tags_tab]
    when "hot"
      _index_tab_hot
    when "recently_used"
      _index_tab_recently_used
    when "another_name"
      _index_tab_another_name
    else
      _index_tab_hot
    end
  end

  def _index_tab_hot
    set_cookies_menu_tags_tab "hot"
    @tags_hash_arr = Tag.hot.paginate(:per_page=>40,:page=>params[:page]||1)
    render :template=>"tags/hot"
  end

  def _index_tab_recently_used
    set_cookies_menu_tags_tab "recently_used"
    @tags_hash_arr = Tag.recently_used.paginate(:per_page=>40,:page=>params[:page]||1)
    render :template=>"tags/recently_used"
  end

  def _index_tab_another_name
    set_cookies_menu_tags_tab "another_name"
    @tags = Tag.has_another_name.paginate(:per_page=>40,:page=>params[:page]||1)
    render :template=>"tags/another_name"
  end

  private
  def set_cookies_menu_tags_tab(name)
    cookies[:menu_tags_tab] = name
  end


end
