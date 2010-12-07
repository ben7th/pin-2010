module NotesHelper
  def show_blob(note,blob)
    case blob.mime_type
    when 'image/jpeg','image/png','image/gif'
      "<img class='logo' src='/notes/#{note.id}/raw/#{blob.id}/#{blob.basename}'/>"
    else
      blob.data
    end
  end
end
