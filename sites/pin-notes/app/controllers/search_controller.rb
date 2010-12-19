class SearchController < ApplicationController
  def show
     respond_to do |format|
      format.html do
        @query = params[:q]
        begin
          @result = NoteLucene.search_full(params[:q])
        rescue Thrift::TransportException => ex
          return render_status_page(500,'搜索服务出现错误，或者正在维护')
        rescue Exception => ex
          return render_status_page(500,'搜索服务出现未知错误')
        end
#        @result = NoteLucene.search_newest(params[:q])
      end
      format.xml do
        render :xml => NoteLucene.search_full_xml(params[:q])
#        render :xml => NoteLucene.search_newest_xml(params[:q])
      end
     end
  end

  def create_index
    @result = NoteLucene.create_index
    render :text=>@result
  end

end