class CollectionsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @collection = Collection.find(params[:id]) if params[:id]
  end

  def new
  end

  def create
    collection = current_user.create_collection_by_params(params[:title],params[:description],params[:sendto])
    unless collection.id.blank?
      return render :partial=>'modules/page_collections',:locals=>{:collections=>[collection]}
    end
    render :text=>"创建失败",:status=>402
  end

  def show
  end
end
