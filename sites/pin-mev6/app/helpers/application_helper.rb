# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # 评论
  def comment_content(comment)
    str = h comment.content
    str.gsub(MindpinTextFormat::AT_REG) do
      "<a href='/atmes/#{$1}'>@#{$1}</a>"
    end
  end

end
