module WorkspacesHelper

  def show_operate_by_status(workspace)
    membership = Membership.find_by_workspace_id_and_email(workspace.id,current_user.email)
    return "" if workspace.user == current_user || workspace.baned_member_emails.include?(current_user.email)
    case true
    when workspace.member_emails.include?(current_user.email)
      return link_to "退出",quit_workspace_memberships_path(workspace,:code=>membership.uuid_code)
    when workspace.apply_member_emails.include?(current_user.email)
      return "已经申请，请等待"
    else
      return link_to "申请",apply_join_workspace_memberships_path(workspace),:method=>:post
    end
  end

  def operate_info(info)
    workspace = info.workspace
    document = Document.find_by_log_info(info)
    user = User.find_by_email(info.email)

    render :partial=>'workspaces/parts/operation_info',:locals=>{
      :info=>info,
      :workspace=>workspace,
      :document=>document,
      :user=>user
    }
  end

  def operate_str(info)
    document = Document.find_by_log_info(info)
    text_pin = document.find_text_pin(info.text_pin_id) if !info.text_pin_id.blank?

    case info.operate
      when 'create' then "创建了话题"
      when 'reply' then "回复内容 #{text_pin.to_html} 到话题"
      when 'delete' then "删除了内容 在话题"
      when 'edit' then "编辑了内容 #{text_pin.to_html} 到话题"
    end
  end

  def document_link(document)
    title = document.title

    match_data = title.match(/<bundle>.*<\/bundle>(.*)/)
    if match_data
      bundle_title = match_data[1]
      bundle_title = "无标题" if bundle_title.blank?
      title = "bundle(#{bundle_title})"
    end

    link_to title,pin_url_for('discuss',"workspaces/#{document.discussion.workspace.id}/documents/#{document.id}")
  end

  def workspace_link(workspace)
    link_to workspace.name,"workspaces/#{workspace.id}"
  end
    
end