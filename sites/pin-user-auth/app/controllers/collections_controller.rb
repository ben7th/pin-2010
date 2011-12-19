class CollectionsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @collection = Collection.find(params[:id]) if params[:id]
  end

  def index
    @user = User.find(params[:user_id]) if params[:user_id]
    @user ||= current_user

    @collections = @user.created_collections
  end

  def show
  end

  def create
    @collection = current_user.create_collection_by_params(params[:title])
    
    unless @collection.id.blank?
      render :partial=>'collections/parts/grid',:locals=>{:collections=>[@collection]}
    else
      render :text=>"创建失败",:status=>422
    end
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
