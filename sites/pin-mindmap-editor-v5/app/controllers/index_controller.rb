class IndexController < ApplicationController
  def index
    if logged_in?
      return redirect_to user_mindmaps_url(current_user)
    end
    return redirect_to mindmaps_url
  end

  def search
    begin
      @pagetitle='思维导图搜索结果'
      @query = params[:q]

      if @query.blank?
        @mindmaps=Mindmap.paginate(:conditions=>['1=0'],:page => params[:page]||1, :per_page => 10)
        return
      end
      @query = @query.split(" ")*"|"

      # 导图
      @mindmaps = Mindmap.search(@query,:page => params[:page]||1, :per_page => 10,:match_mode => :boolean)
      # 如果全文索引服务有问题，这个会抛异常
      @mindmaps.each
      
    rescue Exception => ex
      @sphinx_error = '全文搜索服务工作异常，已经切换至普通搜索'
      @mindmaps=Mindmap.paginate(:conditions=>['title like ?',"%#{@query}%"],:page => params[:page]||1, :per_page => 10)
    end
  end

end
