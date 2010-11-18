class BrowserExtensionController < ApplicationController
  before_filter :login_required

  include WebSiteHelper
  
  # 网站资料  和 评论
  def site_info
    site_info_json = build_site_info_json(params[:url])
    respond_to do |format|
      format.json { render :json=>site_info_json}
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
