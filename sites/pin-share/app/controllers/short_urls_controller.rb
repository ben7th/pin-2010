class ShortUrlsController < ApplicationController

  def show
    short_url = ShortUrl.find_by_code params[:code]
    if short_url
      return redirect_to short_url.url
    end
    return render :status=>404,:text=>"地址无效"
  end
  
end
