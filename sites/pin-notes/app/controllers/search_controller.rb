class SearchController < ApplicationController
  def show
    @query = params[:q]
    begin
      @result = NoteLucene.search_paginate_full(params[:q],:page=>params[:page])
    rescue Thrift::TransportException => ex
      return render_status_page(500,'搜索服务出现错误，或者正在维护')
    rescue Exception => ex
      return render_status_page(500,'搜索服务出现未知错误')
    end
    #        @result = NoteLucene.search_newest(params[:q])
  end

  def create_index
    @result = NoteLucene.create_index
    render :text=>@result
  end

end