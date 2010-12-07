class NotesController < ApplicationController
  #  before_filter :login_required,:except=>[:show]
  before_filter :per_load
  def per_load
    @note = Note.find(params[:id]) if params[:id]
    @note = Note.find(params[:note_id]) if params[:note_id]
  end

  def index
  end
  
  def new
    set_tabs_path("notes/tabs")
    claim_notes_str = cookies[:notes]
    if !claim_notes_str.blank? && current_user
      claim_notes_str.split(",").each do |id|
        note = Note.find_by_id(id)
        note.update_attributes(:user_id=>current_user.id) if note
      end
      cookies[:notes] = {:value=>nil,:domain=>'mindpin.com'}
    end
  end

  def show
      respond_to do |format|
      format.html do
        set_tabs_path(false)
        repo = @note.repo
        @commit_ids = repo.commit_ids
        @commit_id = (params[:commit_id] || @commit_ids.first)
        @can_edit = _can_edit?(@note,@commit_id)
        @comments = @note.comments
        @blobs = repo.blobs(@commit_id)
      end
      format.js do
        @file_name = params[:file]
        @file_content = @note.repo.text_hash[@file_name]
        str = @template.render(:partial=>'notes/parts/embed.haml',
          :locals=>{:file_name=>@file_name,:file_content=>@file_content,:note=>@note})
        render :text=>"document.write(#{str.to_json})",:layout=>false
      end
      end
  end

  def _can_edit?(note,commit_id)
    _can_edit_by_commit_id(note,commit_id) && _can_edit_by_owner?
  end

  def _can_edit_by_commit_id(note,commit_id)
    commit_id == "master" || commit_id == note.repo.commit_ids.first
  end

  def _can_edit_by_owner?
    # 用户存在 可以编辑自己的
    # 没有登录的 cookie中存在的临时note可以编辑
    current_user || current_user.blank? && cookies[:notes] && cookies[:notes].split(",").include?(params[:id])
  end

  def download
    path = @note.zip_pack(params[:commit_id])
    send_file path,:type=>"application/zip",:disposition=>'attachment',:filename=>"note-#{@note.id}-#{params[:commit_id]}.zip"
  end

  def create
    attrs = params[:note]
    user_id = logged_in? ? current_user.id : 0
    attrs.merge!(:user_id=>user_id)
    _private = (params[:commit] == "private")
    attrs.merge!(:private=>_private)
    
    note = Note.create(attrs)
    set_cookie_if_nobody(note)
    note.repo.replace_notefiles(_notefile_hash)
    redirect_to note_path(note)
  end

  def _notefile_hash
    files = params[:file]
    params[:file_name].each do |old_name,new_name|
      if !new_name.blank?
        files.merge!({new_name=>files.delete(old_name)})
      end
    end
    return files
  end

  def set_cookie_if_nobody(note)
    if current_user.blank?
      value = cookies[:notes].blank? ? note.id : cookies[:notes]+",#{note.id}"
      cookies[:notes] = {:value=>value,:expires=>3.days.from_now,:domain=>'mindpin.com'}
    end
  end

  def edit
    @text_hash = @note.repo.text_hash
  end

  def update
    @note.update_attributes(params[:note])
    @note.save
    @note.repo.replace_notefiles(_notefile_hash)
    redirect_to note_path(@note)
  end

  def destroy
    @note.destroy
    redirect_to "/"
  end

  def add_another
    file_name = "#{NoteRepository::NOTE_FILE_PREFIX}#{params[:next_id]}"
    str = @template.render :partial=>"notes/parts/notefile_input",
      :locals=>{:file_name=>file_name}
    render :text=>str
  end

  def upload_page
    set_tabs_path(false)
  end

  def upload
    @note.repo.add_file(params[:file])
    redirect_to note_path(@note)
  end

  def raw
    cache_path = File.join(NoteRepository::BLOB_CACHE_PATH,params[:blob_id],params[:file_name])
    if !File.exist?(cache_path)
      # 建立缓存
      blob = @note.repo.repo.blob(params[:blob_id])
      FileUtils.mkdir_p(File.dirname(cache_path))
      File.open(cache_path,"w"){|f|f << blob.data}
    end
    send_file cache_path, :filename =>params[:file_name], :disposition => 'inline'
  end

end
