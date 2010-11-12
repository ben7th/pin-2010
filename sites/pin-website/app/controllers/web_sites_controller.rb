class WebSitesController < ApplicationController
  before_filter :login_required
  before_filter :pre_load

  def index
    @web_sites = WebSite.all.paginate(:page => params[:page] ,:per_page=>20 )
  end

  def new
    render_ui do |ui|
      ui.fbox :show,:partial=>"web_sites/form_web_site",:title=>"新添收藏网站"
    end
  end

  def create
    url = params[:url]
    url_str = URI.parse(url)
    domain = url_str.host
    @web_site = WebSite.create_web_site(domain)
    if @web_site
      render_ui do |ui|
        ui.fbox :close
        ui.mplist :insert,@web_site,:prev=>:TOP
      end
      return
    end
  end

  def show
    redirect_to web_site_introductions_path(@web_site)
  end

  def pre_load
    @web_site = WebSite.find(params[:id]) if params[:id]
  end
end
