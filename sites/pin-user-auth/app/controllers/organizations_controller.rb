class OrganizationsController < ApplicationController

  before_filter :per_load
  def per_load
    @organization = Organization.find(params[:id]) if params[:id]
  end

  def index
    
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])
    if @organization.save
      @organization.members.create(:email=>current_user.email,:kind=>Member::KIND_OWNER)
      return redirect_to invite_organization_path(@organization)
    end
    render :action=>:new
  end

  def settings
  end

  def leave
    
  end

  def invite;end

  def show;end
end


