class CreateFeedsController < ApplicationController
  before_filter :login_required

  def html_document_feed
    channel_id = params[:channel_id]
    res = current_user.send_html_document_feed(params[:title],params[:html],:channel_ids=>[channel_id])
    redirect_to "/channels/#{channel_id}"
  end

  def mindmap_feed
    channel_id = params[:channel_id]
    res = current_user.send_mindmap_feed(params[:title],:channel_ids=>[channel_id])
    redirect_to "/channels/#{channel_id}"
  end

end
