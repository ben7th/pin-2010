class MembershipsController < ApplicationController

  before_filter :per_load
  def per_load
    @workspace = Workspace.find(params[:workspace_id]) if params[:workspace_id]
    @membership = Membership.find(params[:id]) if params[:id]
  end

  before_filter :is_manager,:only=>[
    :add_members_form,:add_members,:invite_members_form,:invite_members,
    :approve,:members_manage,:kick_out,:ban,:unban
    ]
  def is_manager
    if current_user != @workspace.user
      render :status=>500,:text=>"500"
    end
  end

  def create
    workspace_id = params[:membership][:workspace_id]
    email = params[:membership][:email]
    @membership = Workspace.find(workspace_id).add_member(email)
    if @membership
      render :xml=>@membership.to_xml
    end
  end

  def add_members_form;end

  def get_emails
    params[:emails].split(/,|，|\r?\n/)
  end

  def add_members
    @emails = get_emails
    @message = params[:message]
    # 发送邮件
    @workspace.add_members(@emails)
    @emails.each{|email|Mailer.deliver_welcome_to_workspace(@workspace,@message,email)}
    render :template=>"/memberships/add_success"
  end

  def invite_members_form;end

  def invite_members
    @emails = get_emails
    @message = params[:message]
    # 发送邮件
    @workspace.invite_members(@emails)
    @emails.each{|email|Mailer.deliver_invite_to_workspace(@workspace,@message,email)}
    render :template=>"/memberships/invite_success"
  end

  def quit
    membership = Membership.find_by_uuid_code(params[:code])
    if membership.quit
      return render :template=>"/memberships/quit_success"
    end
    render :template=>"/memberships/aleady_quited"
  end

  def join
    membership = Membership.find_by_uuid_code(params[:code])
    message = membership.join
    return render :template=>"/memberships/join_result",:locals=>{:message=>message}
  end

  def apply_join
    current_user.apply_join(@workspace)
    redirect_to @workspace
  end

  def approve
    @membership.approve
    redirect_to_members_manage
  end

  def refuse
    @membership.refuse
    redirect_to_members_manage
  end

  def members_manage;end

  def kick_out
    @membership.quit
    redirect_to_members_manage
  end

  def ban
    @membership.ban
    redirect_to_members_manage
  end

  def unban
    @membership.unban
    redirect_to_members_manage
  end

  def redirect_to_members_manage
    redirect_to :action=>:members_manage
  end
  
end