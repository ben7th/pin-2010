class BrowserExtensionController < ApplicationController
  before_filter :login_required

  skip_before_filter :verify_authenticity_token
  include WebSiteHelper
  include WebSiteVisitHelper
  
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
    from = (params["from"] || 0).to_i
    count = (params["count"] || 10).to_i
    browse_histories = current_user.browse_histories.from_size(from,count)
    
    respond_to do |format|
      format.json { render :json=>build_browse_histories_json(browse_histories)}
      format.any
    end
  end

  # 历史记录的统计图
  def browse_histories_chart
    respond_to do |format|
      format.xml { render :xml=>chart_xml(params[:order])}
      format.any
    end
  end
  
end
