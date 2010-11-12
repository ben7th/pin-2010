class InstallingsController < ApplicationController

  before_filter :pre_load

  def index
  end

  # 安装应用
  def create
    app_install = Installing.new(:app=>@app,:user=>current_user)
    app_install.save
    return redirect_to "/app/#{@app.name}"
  end

  # 卸载应用
  def destroy
    app = @install.app
    @install.destroy
    render_ui do |ui|
      ui.mplist :update,app,:partial=>"apps/parts/mpinfo_app",:locals=>{:app=>app}
    end
  end

  # 安装思维导图
  def install_mindmap
    current_user.install_mindmap_to_usually
    flash[:notice] = '思维导图安装成功，您可以通过页面右上角的导航快速进入思维导图'
    redirect_to "/welcome"
  end

  def pre_load
    @install = Installing.find(params[:id]) if params[:id]
    @app = App.find(params[:app_id]) if params[:app_id]
  end
  
end
