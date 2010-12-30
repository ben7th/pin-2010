module MindmapShowImageMethods
  def show_image(format)
    if !has_view_rights?(@mindmap,current_user)
      return render :file=>File.join(RAILS_ROOT,"public/images/private_mindmap.png"),:status=>403
    end
    zoom = params[:zoom].blank? ? 1 : params[:zoom].to_f
    file_path = @mindmap.get_img_path_by(zoom.to_s)
    if stale?(:last_modified => @mindmap.updated_at,:etag =>@mindmap.updated_at)
      send_file file_path,:type=>"image/#{format}",:disposition=>'inline'
    end
  end
  
  def mime_type(file_name)
    guesses = MIME::Types.type_for(file_name) rescue []
    guesses.first ? guesses.first.simplified : "text/plain"
  end
end
