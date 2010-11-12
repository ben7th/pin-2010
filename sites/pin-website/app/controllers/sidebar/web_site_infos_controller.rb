class Sidebar::WebSiteInfosController < ApplicationController
  before_filter :login_required
  before_filter :pre_load
  layout "sidebar"
  def pre_load
    @ws_domain = URI.parse(params[:url]).host if params[:url]
    @web_site = WebSite.find_by_domain(@ws_domain) if @ws_domain
  end

  def show;end

end
