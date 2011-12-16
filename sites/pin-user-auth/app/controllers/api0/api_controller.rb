class Api0::ApiController < ApplicationController
  before_filter :api0_need_login
  def api0_need_login
    return render :text=>'api0需要在登录状态下访问',:status=>401 if !logged_in?
  end

  include ApiCommentMethods
  include ApiCollectionMethods

  # 手机客户端使用的数据同步方法
  def mobile_data_syn
    collections = current_user.created_collections
    return render :json=>{
      :user        => api0_user_json_hash(current_user),
      :collections => collections.map{|collection|
        api0_collection_json_hash(collection)
      }
    }
  end



  # 获取当前用户以及其所有联系人的主题列表
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  # :max_id 非必须，若指定此参数，则只获取ID小于或等于max_id的feed信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def home_timeline
    feeds = current_user.home_timeline({
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    })

    render :json=>feeds.map{|feed|
      api0_feed_json_brief_hash(feed)
    }
  end

  # 根据id获取单条feed信息
  # :id 必须，feed的ID
  def show
    feed = Feed.find(params[:id])
    feed.save_viewed_by(current_user) if feed && current_user # 保存feed被用户查看过的记录
    
    render :json=>api0_feed_json_hash(feed)
  end

  # 发送一个主题
  # :title 非必须
  # :detail 非必须
  #
  # :photo_ids 必须，一个到多个photo的id（从 upload_photo 方法返回结果中获得），用英文逗号 ',' 隔开
  # 如果要上传图片，需要先调用 upload_photo
  #
  # * 注：以上三个参数虽然都是非必须，但至少要有其中一个，否则400错误（请求参数错误）
  #
  # :collection_ids 必须，一个到多个收集册的id，用英文逗号 ',' 隔开
  # :send_tsina 非必须，是否发送到新浪微博 取值为字符串的 true 或 false
  # :location 非必须，地理位置经纬度信息
  def create
    feed = Apiv0.send_feed_by_user(
      current_user,
      :title          => params[:title],
      :detail         => params[:detail],
      :photo_ids      => params[:photo_ids],
      :collection_ids => params[:collection_ids],
      :send_tsina     => params[:send_tsina],
      :from           => Feed::FROM_ANDROID,
      :location       => params[:location]
    )

    render :json=>api0_feed_json_hash(feed)
  rescue Apiv0::ParamsNotValidException => e
    render :text=>"api0 参数错误：#{e.message}", :status=>400
  end

  
  # 上传一张图片
  # file 必须，binary二进制内容，上传的图片
  # * 注 此方法将返回photo id，该id在后续执行 create 时将用到
  def upload_photo
    photo = PhotoAdpater.create_photo_by_upload_file(current_user, params[:file])
    render :json=>{:photo_id=>photo.id}
  end

  # -------------------------

  # 获取指定用户的关注对象（TA关注的人）列表
  # :user_id 必须，用户id
  def contacts_followings
    user = User.find(params[:user_id])
    render :json=>user.followings.map{|u|
      api0_user_json_hash(u)
    }
  end

  def test
  end

  # -------- 以下是一些私有方法 用来包装数据 --------
  private
    def api0_feed_json_hash(feed)
      return nil if feed.blank?

      user = feed.creator
      feed_format = FeedFormat.new(feed)

      photos = feed.photos
      photos_count = feed.photos.count

      @_feed_jh ||= {}
      return @_feed_jh[feed] ||= {
        :created_at => feed.created_at.localtime,
        :updated_at => feed.updated_at.localtime,
        :id         => feed.id,
        :title      => feed_format.title,
        :detail     => feed_format.detail,
        :from       => feed.from,
        :comments_count   => feed.main_post.comments.count,
        :photos_thumbnail => photos.map{|p|p.image.url(:s100)},
        :photos_middle    => photos.map{|p|p.image.url(:w250)},
        :photos_large     => photos.map{|p|p.image.url(:w500)},
        :photos_ratio     => photos.map{|p|p.image_ratio},
        :photos_count     => photos_count,
        :brief            => false,
        :user        => api0_user_json_hash(user)
      }
    end

    def api0_feed_json_brief_hash(feed)
      return nil if feed.blank?

      user = feed.creator
      feed_format = FeedFormat.new(feed)

      brief_photos = feed.photos.all(:limit=>3)
      photos_count = feed.photos.count

      @_feed_jbh ||= {}
      return @_feed_jbh[feed] ||= {
        :created_at => feed.created_at.localtime,
        :updated_at => feed.updated_at.localtime,
        :id         => feed.id,
        :title      => feed_format.title_brief,
        :detail     => feed_format.short_detail_brief,
        :from       => feed.from,
        :comments_count   => feed.main_post.comments.count,
        :photos_thumbnail => brief_photos.map{|p|p.image.url(:s100)},
        :photos_middle    => brief_photos.map{|p|p.image.url(:w250)},
        :photos_large     => brief_photos.map{|p|p.image.url(:w500)},
        :photos_ratio     => brief_photos.map{|p|p.image_ratio},
        :photos_count     => photos_count,
        :brief            => true,
        :user       => api0_user_json_hash(user)
      }
    end

    def api0_comment_json_hash(comment)
      return nil if comment.blank?

      user = comment.user
      feed = comment.feed

      @_comment_jh ||= {}
      return @_comment_jh[comment] ||= {
        :created_at => comment.created_at.localtime,
        :id         => comment.id,
        :content    => comment.content,
        :user => api0_user_json_hash(user),
        :feed => api0_feed_json_brief_hash(feed)
      }
    end

    def api0_user_json_hash(user)
      return nil if user.blank?
      
      @_user_jh ||= {}
      return @_user_jh[user] ||= user.api0_json_hash(current_user)
    end

    def api0_collection_json_hash(collection)
      return nil if collection.blank?

      @_collection_jh ||= {}
      return @_collection_jh[collection] ||= {
        :created_at  => collection.created_at.localtime,
        :updated_at  => collection.updated_at.localtime,
        :id          => collection.id,
        :title       => collection.title,
        :user        => api0_user_json_hash(collection.creator),
        :description => collection.description || ''
      }
    end
end
