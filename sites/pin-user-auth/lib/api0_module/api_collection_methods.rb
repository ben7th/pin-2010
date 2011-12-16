module ApiCollectionMethods

  # 获取指定的收集册中的主题列表
  # :collection_id 必须  收集册的id
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的feed信息
  # :max_id 非必须，若指定此参数，则只获取ID小于或等于max_id的feed信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def collection_feeds
    collection = Collection.find(params[:collection_id])
    feeds = collection.feeds_limit({
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    })

    render :json=>feeds.map{|feed|
      api0_feed_json_brief_hash(feed)
    }
  end

  # 获取当前登录用户的收集册列表
  def collection_list
    collections = current_user.created_collections
    return render :json=>collections.map{|collection|
      api0_collection_json_hash(collection)
    }
  end
  
  # 创建一个收集册
  # :title 必须，收集册的标题
  def create_collection
    collection = current_user.create_collection_by_params(params[:title])

    unless collection.id.blank?
      render :json=>current_user.created_collections.map{|c|
        api0_collection_json_hash(c)
      }
    else
      render :text=>"api0 收集册创建失败",:status=>400
    end
  end

  # 删除一个收集册
  # :collection_id 必须  收集册的id
  def delete_collection
    collection = Collection.find(params[:collection_id])
    collection.destroy
    render :json=>current_user.created_collections.map{|c|
      api0_collection_json_hash(c)
    }
  end

  # 重命名一个收集册
  # :collection_id 必须  收集册的id
  # :title 必须，收集册的标题
  def rename_collection
    collection = Collection.find(params[:collection_id])
    if collection.update_attributes(:title=>params[:title])
      return render :json=>current_user.created_collections.map{|c|
        api0_collection_json_hash(c)
      }
    end
    render :text=>"api0 收集册重命名失败",:status=>400
  end

end
