module MindmapHelper
  def node_title_to_br(str)
    str = CGI.escapeHTML(str)
    str.strip().gsub(/\n+/,"<br/>").gsub("\s"," ")
  end

  def userlink(mindmap)
    link_to "<mp:user-name userid='#{mindmap.user_id}'/>","/users/#{mindmap.user_id}",:class=>'username'
  end

  def thumb_image(mindmap)
    "<img src='/thumbs/#{mindmap.id}.png' alt='#{mindmap.title}' />"
  end

  def get_list_base_data
    return _get_a_user_s_list_base_data if _is_visiting_a_user_s_list?
    return _get_public_list_base_data
  end

  def _is_visiting_a_user_s_list?
    !!params[:user_id]
  end

  def _get_a_user_s_list_base_data
    map_data = {}
    if @user == current_user
      map_data[:sub_title] = "我的导图"
      map_data[:map_count] = @user.mindmaps.count
    else
      map_data[:sub_title] = "#{@user.name}的公开导图"
      map_data[:map_count] = @user.mindmaps.publics.count
    end
    map_data[:partial] = 'mindmaps/list/mindmaplist'
    return map_data
  end

  def _get_public_list_base_data
    map_data = {}
    map_data[:sub_title] = "全部公开导图"
    map_data[:map_count] = Mindmap.publics.count
    map_data[:partial] = 'mindmaps/list/mindmapgrid'
    return map_data
  end
  
  def show_operation_links?(mindmap)
    logged_in? && mindmap.user_id == current_user.id
  end

  def classname_hide_private(mindmap)
    mindmap.private? ? "private-mark-link" : "not-private-mark-link"
  end

  def escape_title(mindmap,size = nil)
    if size.nil?
     return CGI.escapeHTML(mindmap.title)
    end
    CGI.escapeHTML(truncate_u(mindmap.title,size))
  end

  def get_workspaces
    return if !!@workspaces || (@workspaces == [])
    xml = HandleGetRequest.get_response(File.join(WORKSPACE_SITE,"workspaces/list.xml?req_user_id=#{current_user.id}")).body
    @workspaces = Hash.from_xml(xml)["workspaces"] || []
  end

end
