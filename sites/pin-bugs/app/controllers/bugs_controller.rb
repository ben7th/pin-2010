class BugsController < ApplicationController

  before_filter :per_load

  def create
    @bug = Bug.new(params[:bug])
    @bug.user_agent = request.user_agent
    if logged_in?
      @bug.user = current_user
      return create_success if @bug.save
    else
      @bug.user_ip = request.remote_ip
      return create_success if @bug.save_with_captcha
    end
    responds_to_parent do
      render_ui do |ui|
        ui.page << "$('new_bug').update(#{(render :partial=>"bugs/form_bug",:locals=>{:bug=>@bug}).to_json})"
      end
    end
  end

  def create_success
    responds_to_parent do
      render_ui do |ui|
        ui.page << %`try{`
        ui.mplist :insert,@bug,:prev=>'TOP'
        ui.page << "$('new_bug').update(#{(render :partial=>"bugs/form_bug",:locals=>{:bug=>Bug.new}).to_json})"
        ui.page << "$$('form#new_bug')[0].reset();"
        ui.page << %`}catch(e){}`
      end
    end
  end

  def index
    @bugs = Bug.find(:all,:order=>"created_at desc").paginate(:page => params[:page] ,:per_page=>10 )
  end

  def show
  end

  def update
    case params[:operate]
    when 'handle'
      @bug.handled!
      return render_ui do |ui| ui.mplist :update,@bug end
    when 'close'
      @bug.closed!
      return render_ui do |ui| ui.mplist :update,@bug end
    end
  end

  def destroy
    if current_user.is_admin?
      @bug.destroy
      render_ui do |ui|
        ui.mplist :remove,@bug
      end
      return
    end
    return render :status=>403,:text=>"无权限"
  end

  def per_load
    @bug = Bug.find(params[:id]) if params[:id]
  end
end