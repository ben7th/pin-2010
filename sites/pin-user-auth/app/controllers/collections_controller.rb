class CollectionsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  skip_before_filter :verify_authenticity_token,
    :only=>[:index,:create,:destroy,:change_name]
  before_filter :verify_authenticity_token_by_client,
    :only=>[:index,:create,:destroy,:change_name]
  def verify_authenticity_token_by_client
    verify_authenticity_token unless is_android_client?
  end
  
  def per_load
    @collection = Collection.find(params[:id]) if params[:id]
  end

  def index
    user = current_user
    user = User.find(params[:user_id]) if params[:user_id]
    @collections = user.created_collections_db
    if is_android_client?
      render :json=>@collections
    else
      render :layout=>'collection'
    end
  end

  def tsina
    @user = User.find(params[:user_id]) if params[:user_id]
    render :layout=>'collection'
  end

  def show
    if is_android_client?
      feeds = @collection.creator.out_feeds
      render :json=>feeds.map{|feed|{:id=>feed.id,:title=>feed.title}}
    else
      render :layout=>'collection'
    end
  end

  def create
    @collection = current_user.create_collection_by_params(params[:title])
    if is_android_client?
      _create_android_render
    else
      _create_web_render
    end
  end

  def _create_web_render
    unless @collection.id.blank?
      render :partial=>'collections/parts/grid',:locals=>{:collections=>[@collection]}
    else
      render :text=>"创建失败",:status=>422
    end
  end

  def _create_android_render
    unless @collection.id.blank?
      render :json=>current_user.created_collections_db
    else
      render :text=>"创建失败",:status=>422
    end
  end

  def destroy
    @collection.destroy
    if is_android_client?
      render :json=>current_user.created_collections_db
    else
      render :text=>"删除成功",:status=>200
    end
  end

  def change_name
    if @collection.update_attributes(:title=>params[:title])
        if is_android_client?
          return render :json=>current_user.created_collections_db
        else
          return render :status=>200, :text=>"修改成功"
        end
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
