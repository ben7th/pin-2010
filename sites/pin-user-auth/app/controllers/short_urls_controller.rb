class ShortUrlsController < ApplicationController

  def show
    code = params[:code]
    url = ShortUrl.get_url_by_code(code)
    if url.blank?
      return render_status_page("404","没有找到这个页面")
    end
    redirect_to url
  end

end


