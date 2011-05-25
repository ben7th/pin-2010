class TagsController < ApplicationController
  before_filter :per_load
  def per_load
    if params[:id]
      @tag = Tag.get_tag_by_full_name(params[:id])
      render_status_page(404,"标签没有找到") if @tag.blank?
    end
  end

  def show
    @feeds = @tag.feeds_limited(20)
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

  before_filter :login_required,:only=>[:fav,:unfav]
  def fav
    current_user.do_fav(@tag)
    render :stats=>200,:text=>"关注成功"
  end

  def unfav
    current_user.do_unfav(@tag)
    render :stats=>200,:text=>"取消关注成功"
  end
end
