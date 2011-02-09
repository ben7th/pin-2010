module MindmapFindingControllerMethods

#  def get_mindmaps(user_id)
#    return get_mindmaps_of_user_id(user_id) if user_id
#    return all_public_mindmaps
#  end

  def get_mindmaps_of_user(user)
    return get_current_user_mindmaps(user) if is_current_user?(user)
    return user.mindmaps.publics.valueable.paginate(paginate_pars)
  end

  def get_current_user_mindmaps(user)
    mindmaps = user.mindmaps
    mindmaps = mindmaps.sort do |a,b|
      case params[:sortby]
      when 'CREATED_TIME' then b.created_at <=> a.created_at
      when 'UPDATED_TIME' then b.updated_at <=> a.updated_at
      else b.created_at <=> a.created_at
      end
    end
    mindmaps.paginate(:page=>params[:page],:per_page=>12)
  end

  def get_all_public_mindmaps
    Mindmap.publics.valueable.paginate(paginate_pars)
  end

  def get_mapdata_of_user(user)
    map_data = {}
    if is_current_user?(user)
      map_data[:sub_title] = "我的导图"
      map_data[:map_count] = user.mindmaps.count
    else
      map_data[:sub_title] = "#{user.name}的公开导图"
      map_data[:map_count] = user.mindmaps.publics.count
    end
    map_data[:partial] = 'mindmaps/list/mindmaplist'
    return map_data
  end

  def get_public_mapdata
    map_data = {}
    map_data[:sub_title] = "全部公开导图"
    map_data[:map_count] = Mindmap.publics.count
    map_data[:partial] = 'mindmaps/list/mindmapgrid'
    return map_data
  end

  def get_order_str_from_params
    case params[:sortby]
      when 'CREATED_TIME' then 'created_at desc'
      when 'UPDATED_TIME' then 'updated_at desc'
      else 'id desc'
    end
  end

  def paginate_pars
    order_str = get_order_str_from_params
    {:order=>order_str,:page=>params[:page],:per_page=>12}
  end

  def is_current_user?(user)
    logged_in? && user == current_user
  end
end
