module MindmapsHelper
  def escape_title(mindmap,size = nil)
    if size.nil?
     return CGI.escapeHTML(mindmap.title)
    end
    CGI.escapeHTML(truncate_u(mindmap.title,size))
  end

  include MindmapRightsHelper
end
