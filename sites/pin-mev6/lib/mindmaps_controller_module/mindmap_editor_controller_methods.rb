module MindmapEditorControllerMethods
  
  # 导出向导页面
  def export
    render_ui.fbox :show,:title=>"导出导图",:partial=>'mindmap_editor/module/box_export',:locals=>{:mindmap=>@mindmap}
  end

  def edit
    if has_edit_rights?(@mindmap,current_user)
      return render :layout=>"mindmap",:template=>'mindmap_editor/editor'
    end
    return render_status_page(403,"当前用户对该导图没有编辑权限。<a href='/mindmaps/#{@mindmap.id}'>点击这里进入查看页</a>")
  end

  def widget
    if @mindmap.private?
      # 私有导图检查权限
      return render :text=>'当前导图是私人可见，无法以组件模式查看',:status=>403
    end

    return (render :layout=>"mindmap",:template=>'mindmap_editor/widget')
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
    
    return (render :layout=>"mindmap",:template=>'mindmap_editor/viewer')
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
    render :json=>{'mindmap'=>{'title'=>@mindmap.title,'created_at'=>@mindmap.created_at}}
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
    file_path = MindmapImageCache.new(@mindmap).export(zoom.to_s)
    
    send_file file_path,:type=>"image/#{format}",:disposition=>'inline'
  end
end
