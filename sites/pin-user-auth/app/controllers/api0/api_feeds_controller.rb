class Api0::ApiFeedsController < ApplicationController
  before_filter :api0_need_login
  def api0_need_login
    return render :text=>'api0需要在登录状态下访问',:status=>401 if !logged_in?
  end

  # 手机客户端使用的数据同步方法
  def mobile_data_syn
    @collections = current_user.created_collections_db
    return render :json=>{
      :user=>current_user.api0_json_hash,
      :collections=>@collections
    }
  end

  # 获取指定的收集册中的主题列表
  # :collection_id 必须  收集册的id
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  # :max_id 非必须，弱指定此参数，则只获取ID小于或等于max_id的feed信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def collection_feeds
    collection = Collection.find(params[:collection_id])
    feeds = collection.feeds_limit({
      :since_id=>params[:since_id],
      :max_id=>params[:max_id],
      :count=>params[:count],
      :page=>params[:page]
    })

    render :json=>feeds.map{|feed|
      api0_feed_json_hash(feed)
    }
  end
  
  # 根据id获取单条feed信息
  # :id 必须，feed的ID
  def show
    feed = Feed.find(params[:id])
    feed.save_viewed_by(current_user) if feed && current_user # 保存feed被用户查看过的记录
    
    render :json=>api0_feed_json_hash(feed)
  end

  # 获取当前用户以及其所有联系人的主题列表
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  # :max_id 非必须，弱指定此参数，则只获取ID小于或等于max_id的feed信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def home_timeline
    feeds = current_user.home_timeline({
      :since_id=>params[:since_id],
      :max_id=>params[:max_id],
      :count=>params[:count],
      :page=>params[:page]
    })

    render :json=>feeds.map{|feed|
      api0_feed_json_hash(feed)
    }
  end


  private
    def api0_feed_json_hash(feed)
      user = feed.creator

      return {
        :created_at => feed.created_at,
        :id         => feed.id,
        :title      => feed.android_title_text,
        :detail     => MindpinTextFormat.new(feed.detail).to_text,
        :from       => feed.from,
        :photos_thumbnail => feed.photos.map{|p|p.image.url(:s100)},
        :photos_middle    => feed.photos.map{|p|p.image.url(:w210)},
        :photos_large     => feed.photos.map{|p|p.image.url(:w660)},
        :user       => user.api0_json_hash(current_user)
      }
    end
end
