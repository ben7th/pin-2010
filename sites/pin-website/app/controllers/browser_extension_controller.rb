class BrowserExtensionController < ApplicationController
  before_filter :login_required

  skip_before_filter :verify_authenticity_token
  include WebSiteHelper
  
  # 网站资料  和 评论
  def site_info
    site_info_json = build_site_info_json(params[:url])
    respond_to do |format|
      format.json { render :json=>site_info_json}
      format.any
    end
  end

  # 创建 评论
  def create_comment
    comment = Comment.new(:url=>params[:url],:content=>params[:content],:creator=>current_user)
    comment.save!
    respond_to do |format|
      format.json { render :json=>build_comment_json(comment)}
      format.any
    end
  end

  # 编辑评论
  def edit_comment
    comment = Comment.find(params[:id])
    comment.update_attributes(:content=>params[:content])
    respond_to do |format|
      format.json { render :json=>build_comment_json(comment)}
      format.any
    end
  end

  # 删除评论
  def destroy_comment
    comment = Comment.find(params[:id])
    comment.destroy
    respond_to do |format|
      format.json { render :json=>{:status=>"OK"}}
      format.any
    end
  end

  # 个人的历史记录
  def browse_histories
    respond_to do |format|
      format.json { render :json=>{:status=>"browse_histories"}}
      format.any
    end
  end
  
end
