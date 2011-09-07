class CollectionsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  skip_before_filter :verify_authenticity_token,:only=>[:index]
  before_filter :verify_authenticity_token_by_client,:only=>[:index]
  def verify_authenticity_token_by_client
    verify_authenticity_token unless is_android_client?
  end
  
  def per_load
    @collection = Collection.find(params[:id]) if params[:id]
  end

  def index
    @collections = current_user.created_collections_db
    if is_android_client?
      render :json=>@collections
    else
      render :layout=>'collection'
    end
  end

  def show
    render :layout=>'collection'
  end

  def create
    collection = current_user.create_collection_by_params(params[:title])
    unless collection.id.blank?
      return render :partial=>'collections/parts/grid',:locals=>{:collections=>[collection]}
    end
    render :text=>"创建失败",:status=>402
  end

  def destroy
    @collection.destroy
    render :text=>"删除成功",:status=>200
  end

  def change_name
    if @collection.update_attributes(:title=>params[:title])
      return render :status=>200, :text=>"修改成功"
    end
    return render :status=>402, :text=>"修改失败"
  end

  def change_sendto
    @collection.change_sendto(params[:sendto])
    render :status=>200, :text=>"修改成功"
  end

  def add_feed
    feed = Feed.find(params[:feed_id])
    @collection.add_feed(feed,current_user)
    render :status=>200, :text=>"增加成功"
  end

end
