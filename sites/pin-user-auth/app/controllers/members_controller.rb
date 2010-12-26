class MembersController < ApplicationController

  before_filter :per_load
  def per_load
    @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    @member = Member.find(params[:id]) if params[:id]
  end

  before_filter :is_owner?,:only=>[:create,:destroy]
  def is_owner?
    if !@organization.is_owner?(current_user)
      return render_status_page(403,'您不是管理员，无权做该操作')
    end
    return true;
  end

  def index
    set_tabs_path('organizations/tabs')
    if @organization.is_owner?(current_user)
      return render :template=>"members/index_owner"
    end
  end

  def create
    @member = @organization.members.new(params[:member])
    if @member.save
      Activity.create_add_org_member(current_user,@organization,@member)
      render_ui do |ui|
        ui.mplist :insert,@member
        ui.page << %~
          jQuery('.add-member-failure-info').html('');
          jQuery('#member_email').attr('value','');
        ~
      end
      return 
    end
    render_ui.page << "jQuery('.add-member-failure-info').html('#{@member.errors.first[1]}')"
  end

  def destroy
    if @member.destroy
      render_ui.mplist :remove,@member
    end
  end

  def redirect_to_invite
    redirect_to invite_organization_path(@organization)
  end

  
end


