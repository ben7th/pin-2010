class BrowseHistoriesController < ApplicationController
  
  before_filter :pre_load
  skip_before_filter :verify_authenticity_token,:only=>[:create]

  def pre_load
    @browse_history = BrowseHistory.find(params[:id]) if params[:id]
  end

  def create
    return render(:status=>401,:text=>"没有登录") if current_user.nil?
    browse_history = BrowseHistory.find_or_create(current_user,params)
    if browse_history
      WebSiteVisit.create_new_record(current_user,params['url'])
      return render :status=>200,:text=>"创建成功"
    end
  end

  def destroy
  end

  def index
    @browse_histories = current_user.browse_histories
  end
  
end