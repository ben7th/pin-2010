class LoginWallpapersController < ApplicationController

  def new
  end

  def create
    LoginWallpaper.create!(:image=>params[:image], :title=>params[:title])
    redirect_to :action=>:new
  end

  def index
    @login_wallpapers = LoginWallpaper.order('id DESC').all
  end

  def destroy
    login_wallpaper = LoginWallpaper.find(params[:id])
    login_wallpaper.destroy
    redirect_to :action=>:index
  end

  def get_next
    login_wallpaper = LoginWallpaper.order('id ASC').where('id > ?', params[:id]).first
    login_wallpaper = LoginWallpaper.order('id ASC').first if login_wallpaper.blank?
    _render_wallpaper_info(login_wallpaper)
  end

  def get_prev
    login_wallpaper = LoginWallpaper.order('id DESC').where('id < ?', params[:id]).first
    login_wallpaper = LoginWallpaper.order('id DESC').first if login_wallpaper.blank?
    _render_wallpaper_info(login_wallpaper)
  end

  private
  def _render_wallpaper_info(login_wallpaper)
    cookies[:login_wallpaper_id] = login_wallpaper.id
    render :json => {
      :id     => login_wallpaper.id,
      :width  => login_wallpaper.image.width,
      :height => login_wallpaper.image.height,
      :title  => login_wallpaper.title,
      :src    => login_wallpaper.image.url
    }
  end
  
end
