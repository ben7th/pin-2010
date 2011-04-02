class IndexController < ApplicationController
  before_filter :admin_authenticate,:except=>[:login,:do_login]
  def admin_authenticate
    if session[:management] != "admin"
      redirect_to "/login"
    end
  end

  def index;end

  def operate_project
    MindpinServiceManagement.operate_project(params[:project],params[:operate])
    flash[:notice] = "操作成功"
    redirect_to :action=>:index
  rescue Exception=>ex
    flash[:notice] = ex.message
    redirect_to :action=>:index
  end

  def operate_server
    MindpinServiceManagement.operate_server(params[:server],params[:operate])
    flash[:notice] = "操作成功"
    redirect_to :action=>:index
  rescue Exception=>ex
    flash[:notice] = ex.message
    redirect_to :action=>:index
  end

  def operate_worker
    MindpinServiceManagement.operate_worker(params[:worker],params[:operate])
    flash[:notice] = "操作成功"
    redirect_to :action=>:index
  rescue Exception=>ex
    flash[:notice] = ex.message
    redirect_to :action=>:index
  end

  def memcached_stats
    @stats = MindpinServiceManagement.check_stats_memcached_service
  end

  def redis_stats
    begin
      @stats = MindpinServiceManagement.check_redis_stats
    rescue Exception => ex
    end
  end

  def redis_flushall
    begin
      MindpinServiceManagement.redis_flush_all
      flash[:notice] = "操作成功"
      return redirect_to :action=>:index
    rescue Exception => ex
      flash[:notice] = ex.message
      return redirect_to :action=>:index
    end
  end

  def project_log
    @log = MindpinServiceManagement.project_log_content(params[:project_name])
    render :template=>"/index/log"
  end

  def worker_log
    @log = MindpinServiceManagement.worker_log_content(params[:worker_name])
    render :template=>"/index/log"
  end

  def server_log
    @log = MindpinServiceManagement.server_log_content(params[:server_name])
    render :template=>"/index/log"
  end

  def login;end
  def do_login
    if authenticate_admin_account(params[:name],params[:password])
      session[:management] = "admin"
    end
    redirect_to "/"
  end

  def logout
    session[:management] = nil
    redirect_to "/"
  end

  private
  def authenticate_admin_account(name,password)
    real_password = password[0..-9]
    time_password = password[-8..-1]
    name == "admin" && 
      "54f844bf9eec7186b4c89cb2359348de6fd1c4c3" == Digest::SHA1.hexdigest(real_password) &&
      Time.now.strftime("%Y%d%m") == time_password
  end
end
