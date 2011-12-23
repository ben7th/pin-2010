class LoginWallpapersController < ApplicationController
  before_filter :login_required

  def new
  end

  def create
    LoginWallpaper.create!(:image=>params[:image],:title=>params[:title])
    redirect_to :action=>:new
  end

  def index
    @login_wallpapers = LoginWallpaper.find(:all,:order=>"id desc")
  end

  def destroy
    @login_wallpaper = LoginWallpaper.find(params[:id])
    @login_wallpaper.destroy
    redirect_to :action=>:index
  end

  def get_next_wallpaper
    @login_wallpaper = LoginWallpaper.find(:first,:order=>"id asc",:conditions=>"id > #{params[:id]}")
    if @login_wallpaper.blank?
      @login_wallpaper = LoginWallpaper.find(:first,:order=>"id asc")
    end
    render_wallpaper_info
  end

  def get_prev_wallpaper
    @login_wallpaper = LoginWallpaper.find(:first,:order=>"id desc",:conditions=>"id < #{params[:id]}")
    if @login_wallpaper.blank?
      @login_wallpaper = LoginWallpaper.find(:first,:order=>"id desc")
    end
    render_wallpaper_info
  end

  private
  def render_wallpaper_info
    cookies[:login_wallpaper_id] = @login_wallpaper.id
    render :json=>{
         :id=>@login_wallpaper.id,
         :width=>@login_wallpaper.image.width,
         :height=>@login_wallpaper.image.height,
         :title=>@login_wallpaper.title,
         :src=>@login_wallpaper.image.url
    }
  end


#  GET /login/get_next_wallpaper?id=xxx
#GET /login/get_prev_wallpaper?id=xxx
#
end
