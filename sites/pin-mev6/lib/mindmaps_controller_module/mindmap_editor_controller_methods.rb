module MindmapEditorControllerMethods
  
  # 导出向导页面
  def export
    render_ui.fbox :show,:title=>"导出导图",:partial=>'mindmaps/edit/box_export',:locals=>{:mindmap=>@mindmap}
  end

  def edit
    if !MindpinServiceManagement.worker_start?("mindmap_input_queue_worker")
      return render_status_page(406,"编辑处理服务没有启动")
    end
    if has_edit_rights?(@mindmap,current_user)
      return render :layout=>"mindmap",:template=>'mindmaps/editor_page/editor'
    end
    return render_status_page(403,"当前用户对该导图没有编辑权限。<a href='/mindmaps/#{@mindmap.id}'>点击这里进入查看页</a>")
  end

  def show
    respond_to do |format|
      format.html {_show_html_page}

      format.xml {_build_xml}
      format.js{_build_js}
      format.json {_build_json}

      format.mm {_download_mm}
      format.mmap {_download_mmap}
      format.doc {_download_doc}

      # 以下为导出图片
      format.png {_show_image 'png'}
      format.jpg {_show_image 'jpeg'}
      format.gif {_show_image 'gif'}
    end
  end

  def _show_html_page
    if !has_view_rights?(@mindmap,current_user)
      # 私有导图检查权限
      return render_status_page(403,'当前用户对该导图没有查看权限')
    end
    
    return (render :layout=>"mindmap",:template=>'mindmaps/editor_page/viewer')
  end

  def _build_xml
    if !has_view_rights?(@mindmap,current_user)
      return (render :text=>'<code>private</code>')
    end
    render :text=>@mindmap.struct
  end

  def _build_js
    if !has_view_rights?(@mindmap,current_user)
      return (render :text=>'private')
    end
    render :text=>@mindmap.struct_json
  end

  def _build_json
    if !has_view_rights?(@mindmap,current_user)
      return (render :text=>'private')
    end
    render :json=>{'mindmap'=>{'title'=>@mindmap.title,'logo'=>@mindmap.logo.url,'created_at'=>@mindmap.created_at}}
  end

  def _download_mm
    if !has_view_rights?(@mindmap,current_user)
      return render_status_page(403,'当前用户对该导图没有查看权限，无法下载MM文档')
    end
    v = params[:v] || "9"
    path = FreemindParser.export(@mindmap,v)
    send_data(path,:type=>"*/*",:disposition=>'attachment',:filename=>"#{@mindmap.title.utf8_to_gbk}_v0.#{v}.mm")
  end

  def _download_mmap
    if !has_view_rights?(@mindmap,current_user)
      return render_status_page(403,'当前用户对该导图没有查看权限，无法下载MMAP文档')
    end
    path = MindmanagerParser.export(@mindmap)
    send_file path,:type=>"*/*",:disposition=>'attachment',:filename=>"#{@mindmap.title.utf8_to_gbk}.mmap"
  end

  def _download_doc
    if !has_view_rights?(@mindmap,current_user)
      return render_status_page(403,'当前用户对该导图没有查看权限，无法下载DOC文档')
    end
    path = WordXmlParser.export(@mindmap)
    send_file path,:type=>"*/*",:disposition=>'attachment',:filename=>"#{@mindmap.title.utf8_to_gbk}.doc"
  end

  def _show_image(format)
    if !has_view_rights?(@mindmap,current_user)
      return render :file=>File.join(RAILS_ROOT,"public/images/private_mindmap.png"),:status=>403
    end
    zoom = params[:zoom].blank? ? 1 : params[:zoom].to_f
    file_path = MindmapImageCache.new(@mindmap).get_img_path_by(zoom.to_s)
    if stale?(:last_modified => @mindmap.updated_at,:etag =>@mindmap.updated_at)
      send_file file_path,:type=>"image/#{format}",:disposition=>'inline'
    end
  end
end
