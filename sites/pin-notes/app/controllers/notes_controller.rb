class NotesController < ApplicationController
  #  before_filter :login_required,:except=>[:show]
  include NotesControllerMethods
  before_filter :per_load
  def per_load
    id = params[:id] || params[:note_id]
    @note = Note.find_by_id(id) if id
    if @note && @note.private
      return render_status_page(404,'该资料不存在')
    end
    @note = Note.find_by_private_id(id) if @note.blank? && id
  end

  before_filter :owner_check,:only=>[:edit,:update,:destroy,:upload_page,:upload,:rollback]
  def owner_check
    if !_can_edit_by_owner?(@note)
      return render_status_page(403,'该资料不属于你，你没有权限修改')
    end
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
        begin
          set_tabs_path(false)
          @commit_ids = @note.commit_ids
          @commit_id = (params[:commit_id] || @commit_ids.first)
          @can_rollback = _can_rollback?(@note,@commit_ids,@commit_id)
          @can_fork = _can_fork?(@note)
          @can_edit = _can_edit?(@note,@commit_ids,@commit_id)
          @can_delete = _can_delete?(@note)
          @comments = @note.comments
          @blobs = @note.blobs(@commit_id)
        rescue NoteRepositoryMethods::GitRepoNotFoundError => ex
          render_status_page(500,ex)
        end

      end
      format.js do
        @file_name = params[:file]
        @file_content = @note.text_hash[@file_name]
        str = @template.render(:partial=>'notes/parts/embed.haml',
          :locals=>{:file_name=>@file_name,:file_content=>@file_content,:note=>@note})
        render :text=>"document.write(#{str.to_json})",:layout=>false
      end
    end
  end

  def download
    if request_os_is_windows?
      path = @note.windows_zip_pack(params[:commit_id])
    else
      path = @note.zip_pack(params[:commit_id])
    end
    send_file path,:type=>"application/zip",:disposition=>'attachment',:filename=>"note-#{@note.nid}-#{params[:commit_id]}.zip"
  end

  def create
    attrs = params[:note]
    user_id = logged_in? ? current_user.id : 0
    attrs.merge!(:user_id=>user_id)
    _private = (params[:commit] == "private")
    attrs.merge!(:private=>_private)
    
    note = Note.create(attrs)
    set_cookie_if_nobody(note)
    note.save_text_hash!(_notefile_hash)
    redirect_to note_path(:id=>note.nid)
  end

  def edit
    @blobs = @note.blobs
  end

  def update
    @note.update_attributes(params[:note])
    @note.save_text_hash!(_notefile_hash,_rename_hash)
    redirect_to note_path(:id=>@note.nid)
  end

  def destroy
    @note.destroy
    redirect_to "/"
  end

  def add_another
    file_name = "#{Note::NOTE_FILE_PREFIX}#{params[:next_id]}"
    str = @template.render :partial=>"notes/parts/notefile_input",
      :locals=>{:file_name=>file_name}
    render :text=>str
  end

  def upload_page
    set_tabs_path(false)
  end

  def upload
    @note.add_file!(params[:file])
    redirect_to note_path(:id=>@note.nid)
  end

  def raw
    cache_path = build_blob_cache_file(@note,params[:blob_id],params[:file_name])
    send_file cache_path, :filename =>params[:file_name], :disposition => 'inline',:type =>mime_type(File.join(params[:file_name]))
  end

  def zoom
    zoom_cache_path = build_zoom_blob_cache_file(@note,params[:blob_id],params[:file_name],params[:zoom])
    send_file zoom_cache_path, :filename =>params[:file_name], :disposition => 'inline',:type =>mime_type(File.join(params[:file_name]))
  end

  def rollback
    @note.grit_repo.rollback(params[:commit_id])
    redirect_to note_path(:id=>@note.nid)
  end

  def fork
    note = Note.fork(@note,current_user)
    redirect_to note_path(:id=>note.nid)
  end

end
