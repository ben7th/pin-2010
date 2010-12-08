module NotesControllerMethods

  def _can_edit?(note,commit_ids,commit_id)
    _can_edit_by_commit_id(commit_ids,commit_id) && _can_edit_by_owner?(note)
  end

  def _can_rollback?(note,commit_ids,commit_id)
    _can_rollback_by_commit_id(commit_ids,commit_id) && _can_edit_by_owner?(note)
  end

  def _can_fork?(note)
    (current_user && note.user != current_user) || current_user.blank? && cookies[:notes] && !cookies[:notes].split(",").include?(note.id)
  end

  def _can_rollback_by_commit_id(commit_ids,commit_id)
    commit_id != "master" && commit_id != commit_ids.first
  end

  def _can_edit_by_commit_id(commit_ids,commit_id)
    commit_id == "master" || commit_id == commit_ids.first
  end

  def _can_edit_by_owner?(note)
    # 用户存在 可以编辑自己的
    # 没有登录的 cookie中存在的临时note可以编辑
    (current_user && note.user == current_user) || current_user.blank? && cookies[:notes] && cookies[:notes].split(",").include?(note.id)
  end

  def set_cookie_if_nobody(note)
    if current_user.blank?
      value = cookies[:notes].blank? ? note.id : cookies[:notes]+",#{note.id}"
      cookies[:notes] = {:value=>value,:expires=>3.days.from_now,:domain=>'mindpin.com'}
    end
  end

  def _notefile_hash
    files = params[:file]
    not_update_data = params[:not_update_data] || {}
    not_update_data.each do |old_name,not_update|
      files.delete(old_name) if not_update
    end
    params[:file_name].each do |old_name,new_name|
      if !new_name.blank?
        text = files.delete(old_name)
        files.merge!({new_name=>text}) if !!text
      end
    end
    return files
  end

  def _rename_hash
    rename_hash = {}
    params[:file_name].each do |old_name,new_name|
      if !new_name.blank?
        rename_hash[old_name] = new_name
      end
    end
    rename_hash
  end

  def mime_type(file_name)
    guesses = MIME::Types.type_for(file_name) rescue []
    guesses.first ? guesses.first.simplified : "text/plain"
  end

  # 生成 blob 的缓存文件
  def build_blob_cache_file(note,blob_id,file_names)
    cache_path = File.join(Note::BLOB_CACHE_PATH,blob_id,file_names)
    if !File.exist?(cache_path)
      # 建立缓存
      blob = note.grit_repo.blob(blob_id)
      FileUtils.mkdir_p(File.dirname(cache_path))
      File.open(cache_path,"w"){|f|f << blob.data}
    end
    return cache_path
  end

  # 生成 zoom_blob 的缓存文件
  def build_zoom_blob_cache_file(note,blob_id,file_names,zoom)
    blob_cache_path = build_blob_cache_file(note,blob_id,file_names)
    zoom_blob_cache_path = File.join(Note::BLOB_CACHE_PATH,blob_id,"zoom",zoom,file_names)
    ImgResize.zoom(blob_cache_path,zoom_blob_cache_path,zoom.to_i)
    return zoom_blob_cache_path
  end

end
