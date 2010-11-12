module MindmapFindingMethods

  def get_mindmaps(user_id)
    return get_mindmaps_of_user_id(user_id) if user_id
    return all_public_mindmaps
  end

  def get_order_str_from_params
    case params[:sortby]
    when 'CREATED_TIME' then 'created_at desc'
    when 'UPDATED_TIME' then 'updated_at desc'
    else 'created_at desc'
    end
  end

  def get_mindmaps_of_user_id(user_id)
    return Mindmap.of_user_id(user_id).paginate(paginate_pars) if is_current_user?(user_id)
    return Mindmap.publics.valueable.of_user_id(user_id).paginate(paginate_pars)
  end

  def all_public_mindmaps
    Mindmap.publics.valueable.paginate(paginate_pars)
  end

  def paginate_pars
    order_str = get_order_str_from_params
    {:order=>order_str,:page=>params[:page],:per_page=>9}
  end

  def is_current_user?(user_id)
    user_id.to_s == current_user.id.to_s
  end
end
