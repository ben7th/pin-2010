module PageHelper
  def nav_bar
    active = '公开导图'
    if params[:user_id]
      active = (is_current_user_page) ? '自己的导图':'用户公开导图'
    end
    render :partial=>'layouts/nav',:locals=>{:active=>active}
  end

  def is_current_user_page
    return false if current_user.blank?
    params[:user_id] == current_user.id.to_s
  end

  def map_list_page_title
    re = ''
    if params[:user_id]
      re = "#{@user.name}的导图"
    else
      re = "MindPin公开导图"
    end
    re = "思维导图编辑器 - #{re}"
    content_for :title, re
  end
end
