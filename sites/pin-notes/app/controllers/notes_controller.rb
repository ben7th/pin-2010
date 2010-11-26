class NotesController < ApplicationController
  #  before_filter :login_required,:except=>[:show]
  before_filter :per_load
  def per_load
    @note = Note.find(params[:note_id]) if params[:note_id]
  end

  def index
  end
  
  def new
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
    # 用户存在 可以编辑自己的
    # 没有登录的 cookie中存在的临时note可以编辑 
    @can_show = current_user || current_user.blank? && cookies[:notes] && cookies[:notes].split(",").include?(params["note_id"])
  end

  def create
    note = !!current_user ? current_user.notes.create(params[:note]) : Note.create(params[:note].merge!(:user_id=>0))
    set_cookie_if_nobody(note)
    note.repo.replace_notefiles(params[:notefile])
    redirect_to show_note_path(:note_id=>note.id)
  end

  def set_cookie_if_nobody(note)
    if current_user.blank?
      value = cookies[:notes].blank? ? note.id : cookies[:notes]+",#{note.id}"
      cookies[:notes] = {:value=>value,:expires=>3.days.from_now,:domain=>'mindpin.com'}
    end
  end

  def edit
  end

  def update
    @note.update_attributes(params[:note])
    @note.save
    @note.repo.replace_notefiles(params[:notefile])
    redirect_to show_note_path(:note_id=>@note.id)
  end

  def destroy
    @note.destroy
    redirect_to "/"
  end

  def new_file
    str = @template.render :partial=>"notes/parts/notefile_form",
      :locals=>{:name=>"#{NoteRepository::NOTE_FILE_PREFIX}#{params[:next_id]}",:text=>""}
    render :text=>str
  end

end
