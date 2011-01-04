module MindmapHelper
  def node_title_to_br(str)
    str = CGI.escapeHTML(str)
    str.strip().gsub(/\n+/,"<br/>").gsub("\s"," ")
  end

  def userlink(mindmap)
    user_id = mindmap.user_id
    user = mindmap.user
    title = ""
    title = case true
    when user_id == 0 then "匿名"
    when !!user then user.name
    when !!user_id && !user then "[用户已删除]"
    end
    link_to title,pin_url_for('pin-mindmap-editor',"/users/#{user_id}/mindmaps"),:class=>'username'
  end

  def thumb_image(mindmap)
    "<img src='/thumbs/#{mindmap.id}.png' alt='#{mindmap.title}' />"
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
