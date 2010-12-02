class MembersController < ApplicationController

  before_filter :per_load
  def per_load
    @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    @member = Member.find(params[:id]) if params[:id]
  end

  def index
    set_tabs_path('organizations/tabs')
  end

  def create
    @member = @organization.members.new(params[:member])
    if @member.save
      Activity.create(:operator=>current_user.email,:location=>@organization,:target_type=>"User", :target_id=>@member.user.id,:event=>Activity::ADD_ORG_MEMBER)
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
      Activity.create(:operator=>current_user.email,:location=>@organization,:target_type=>"User", :target_id=>@member.user.id,:event=>Activity::DELETE_ORG_MEMBER)
      render_ui.mplist :remove,@member
    end
  end

  def redirect_to_invite
    redirect_to invite_organization_path(@organization)
  end

  
end


