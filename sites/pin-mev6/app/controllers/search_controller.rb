class SearchController < ApplicationController
  
  def index
    begin
      @query = params[:q]
      @result = MindmapLucene.search_paginate(@query, :page=>params[:page], :per_page=>18)
    rescue MindmapLucene::MindmapSearchFailureError => ex
      return render_status_page(500, ex)
    end
  end
  
end