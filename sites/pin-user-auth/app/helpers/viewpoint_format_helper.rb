module ViewpointFormatHelper
  # 主题
  #-----------------

  def feed_content(feed)
    "#{h(feed.content)}"
  end

  def feed_detail(feed)
    content = feed.detail_content || ''
    find_and_preserve MindpinTextFormat.new(content).to_html
  end



  # 观点
  # -----------
  def viewpoint_memo_format_show(vp)
    find_and_preserve MindpinTextFormat.new(vp.memo).to_html
  end

  def viewpoint_memo_format_in_list(vp)
    s1 = _viewpoint_memo_format_in_list_short(vp)
    s2 = _viewpoint_memo_format_in_list_long(vp)

    if s1.length == s2.length
      re = s1
    else
      re = %~
        <div class='short-content'>#{s1} <a href='javascript:;' class='show-detail font12'>显示全部</a></div>
        <div class='detail-content' style='display:none;'>#{s2}</div>
      ~
    end

    find_and_preserve re
  end

  def _viewpoint_memo_format_in_list_long(vp)
    MindpinTextFormat.new(vp.memo).to_text
  end

  def _viewpoint_memo_format_in_list_short(vp)
    truncate_u(MindpinTextFormat.new(vp.memo).to_text, 64)
  end
end
