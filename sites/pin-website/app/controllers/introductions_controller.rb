class IntroductionsController < ApplicationController

  before_filter :per_load

  def new
    @introduction = Introduction.new
  end

  def create
    @introduction = Introduction.new(params[:introduction])
    @introduction.introductable = @introductable
    @introduction.user = current_user
    if @introduction.save
      return redirect_to @introductable
    end
    return render :action=>:new
  end

  def edit
    @content = @introduction.find_content_of_paragraphs(params[:section])
  end

  # (段落号，内容，用户)
  def update
    @new_introduction = @introduction.edit_content_of_paragraphs(params[:section],params[:content],current_user)
    if @new_introduction.save
      return redirect_to @introductable
    end
    @content = @introduction.find_content_of_paragraphs(params[:section])
    return render :action=>:edit
  end

  def index
    @web_site = WebSite.find(params[:web_site_id])
  end

  def per_load
    @introduction = Introduction.find(params[:id]) if params[:id]
    @introductable = WebSite.find(params[:web_site_id]) if params[:web_site_id]
    @introductable = RssFeed.find(params[:rss_feed_id]) if params[:rss_feed_id]
  end
end
