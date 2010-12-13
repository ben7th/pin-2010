class SearchController < ApplicationController
  def show
     respond_to do |format|
      format.html do
        @query = params[:q]
        @result = NoteLucene.all_search(params[:q])
#        @result = NoteLucene.master_search(params[:q])
      end
      format.xml do
        render :xml => NoteLucene.all_search_xml(params[:q])
#        render :xml => NoteLucene.master_search_xml(params[:q])
      end
     end
  end

  def create_index
    @result = NoteLucene.create_index
    render :text=>@result
  end

end