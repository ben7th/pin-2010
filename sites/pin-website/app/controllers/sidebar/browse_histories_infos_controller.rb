class Sidebar::BrowseHistoriesInfosController < ApplicationController
  before_filter :login_required
  layout "sidebar"
  
  def index
    @browse_histories = current_user.browse_histories_limited
    cookies[:browse_history_order] = params['order'] if params['order']
    @order = cookies[:browse_history_order] || 'count'
  end

  def more
    @more_browse_histories = current_user.browse_histories.from_size(params['from'].to_i,10)
    render_ui do |ui|
      @more_browse_histories.each do |bh|
        ui.mplist :insert,bh
      end
    end
  end

  def one_page
    @browse_historie = BrowseHistory.find_by_url(params['url'])
  end
  
end
