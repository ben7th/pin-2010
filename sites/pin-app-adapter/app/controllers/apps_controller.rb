class AppsController < ApplicationController
  before_filter :login_required
  before_filter :pre_load

  def index
    @apps = App.all
  end

  def installed
    @apps = current_user.installed_apps
    render :template=>"apps/index"
  end

  def new
    app = App.new
    render_ui do |ui|
      ui.fbox :show,:title=>"新应用",:partial=>"/apps/parts/form_app",:locals=>{:app=>app}
    end
  end

  def create
    app = App.new(params[:app])
    if app.save
      responds_to_parent do
        render_ui do |ui|
          ui.fbox :close
          ui.mplist :insert,app,:partial=>"/apps/parts/mpinfo_app"
        end
      end
      return
    end
    responds_to_parent do
      render_ui do |ui|
        ui.fbox :show,:title=>"新应用",:partial=>"/apps/parts/form_app",:locals=>{:app=>app}
      end
    end
  end

  def destroy
    render_ui do |ui|
      ui.mplist :remove,@app
    end
    @app.destroy
  end

  def pre_load
    @app = App.find(params[:id]) if params[:id]
  end

end
