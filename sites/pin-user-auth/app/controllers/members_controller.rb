class MembersController < ApplicationController

  before_filter :per_load
  def per_load
    @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    @member = Member.find(params[:id]) if params[:id]
  end

  def index
    
  end

  def create
    @member = @organization.members.new(params[:member])
    return redirect_to_invite if @organization.has_email?(params[:member][:email])
    if @member.save
      return redirect_to_invite
    end
    redirect_to_invite
  end

  def destroy
    if @member.destroy
      redirect_to_invite
    end
  end

  def redirect_to_invite
    redirect_to invite_organization_path(@organization)
  end

  
end


