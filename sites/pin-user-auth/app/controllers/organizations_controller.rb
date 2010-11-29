class OrganizationsController < ApplicationController

  before_filter :per_load
  def per_load
    @organization = Organization.find(params[:id]) if params[:id]
  end

  def index
    #    @organizations = Organization.of_user(current_user)
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

  def update
    if @organization.update_attributes(params[:organization])
      flash[:success] = "修改成功"
      return redirect_to :action=>:settings
    end
    flash[:error] = "修改失败"
    redirect_to :action=>:settings
  end

  def settings
  end

  def leave
    if @organization.leave(current_user)
      # 离开成功
      flash[:success] = "从 #{@organization.name} 退出成功"
    else
      flash[:notice] = "因为你是本团队唯一的管理者，所以不能退出"
    end
    redirect_to account_organizations_path
  end

  def invite;end

  def show;end
end


