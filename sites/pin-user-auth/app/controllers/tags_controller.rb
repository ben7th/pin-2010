class TagsController < ApplicationController
  before_filter :per_load
  def per_load
    @tag = Tag.find_by_name(params[:id]) if params[:id]
  end

  def show
    @feeds = @tag.feeds_limited(20)
  end

  def logo
    if @tag.update_attribute(:logo,params[:logo])
      render :text=>"logo 保存成功"
    else
      render :text=>"logo 保存失败",:status=>401
    end
  end

  def detail
    if @tag.update_attribute(:detail,params[:detail])
      render :text=>"描述保存成功"
    else
      render :text=>"描述保存失败",:status=>401
    end
  end
end
