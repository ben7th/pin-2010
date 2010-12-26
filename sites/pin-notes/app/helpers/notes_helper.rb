module NotesHelper
  def show_blob(note,blob)
    case blob.mime_type
    when 'image/jpeg','image/png','image/gif'
      "<img class='logo' src='/notes/#{note.nid}/zoom/400/#{blob.id}/#{blob.basename}'/>"
    else
      simple_format(h(blob.data))
    end
  end

  def blob_is_text?(blob)
    mime_type = blob.mime_type
    return false if mime_type.include?('image')
    return true
  end

  def show_commit(note,commit)
    stats = commit.stats
    additions = stats.additions | stats.files.count
    deletions = stats.deletions
    total = additions + deletions

    if additions + deletions <=6
      add = additions
      del = deletions
    else
      add = additions * 6 / total
      del = deletions * 6 / total
    end
    render :partial=>'notes/parts/commit',:locals=>{:note=>note,:commit=>commit,:add=>add,:del=>del}
  end
end
