class MiscController < ActionController::Base
  def concat
  end

  def plugins
  end

  def old_map_redirect
    id = params[:id]
    redirect_to pin_url_for 'pin-mindmap-editor',"/mindmaps/#{id}"
  end
end
