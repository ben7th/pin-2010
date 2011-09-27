class MindpinTextFormat

  AT_REG = /@([A-Za-z0-9]{1}[A-Za-z0-9_]{2,20}|[一-龥]{2,20})/

  FORMAT_HTML = "html"
  FORMAT_MARKDOWN = "markdown"
  FORMAT_TEXT = "text"
  
#  [O]autolink	 [RW] 	 Enable the Autolinking extension
#  [O]fenced_code	 [RW] 	 Enable PHP-Markdown fenced code extension
#  filter_html	 [RW] 	 Do not output any raw HTML included in the source text.
#  [O]filter_styles	 [RW] 	 Do not output <style> tags included in the source text.
#  [O]generate_toc	 [RW] 	 Add TOC anchors to every header
#  [X]gh_blockcode	 [RW] 	 Generate safer HTML for code blocks (no custom CSS classes)
#  [O]hard_wrap	 [RW] 	 Treat newlines in paragraphs as real line breaks, GitHub style
#  [O]lax_htmlblock	 [RW] 	 Allow HTML blocks inside of paragraphs without being surrounded by newlines
#  no_image	 [RW] 	 Do not process ![] and remove <img> tags from the output.
#  [O]no_intraemphasis	 [RW] 	 Do not render emphasis_inside_words
#  no_links	 [RW] 	 Do not process [] and remove <a> tags from the output.
#  [X]safelink	 [RW] 	 Don‘t make hyperlinks from [][] links that have unknown URL types.
#  [XX]smart	 [RW] 	 Set true to have smarty-like quote translation performed.
#  space_header	 [RW] 	 Force a space between header hashes and the header itself
#  [O]strikethrough	 [RW] 	 Enable PHP-Markdown ~~strikethrough~~ extension
#  tables	 [RW] 	 Enable PHP-Markdown tables extension
#  [O]xhtml	 [RW] 	 Generate XHTML 1.0 compilant self-closing tags (e.g. <br/>)

  def initialize(string, text_kind = nil)
    @string = string
    @text_kind = text_kind
  end
  
  def _markdown_to_html_doc
    # 用 Redcarpet 转换输出
    # :autolink         自动链接转换
    # :fenced_code      代码高亮 github的 ```方式
    # :filter_styles    过滤 <style>标签
    # :hard_wrap        换行转<br/>
    # :xhtml            xhtml标准输出
    # :strikethrough    删除线支持 ~~strikethrough~~
    # :no_intraemphasis	Do not render emphasis_inside_words 不转换文字中间的_
    # :generate_toc    在 h1 h2 ... 这些标题上增加toc_0 toc_1这样子的class名
    # :lax_htmlblock	 Allow HTML blocks inside of paragraphs without being surrounded by newlines

    markdown = Redcarpet.new(@string,
      :autolink,
      :fenced_code,
      :filter_styles,
      :generate_toc,
      :hard_wrap,
      :lax_htmlblock,
      :no_intraemphasis,
      :strikethrough,
      :xhtml
    )

    html = markdown.to_html
    return Nokogiri::HTML.fragment("<div>#{html}</div>")
  end

  #-----------------------
  def to_html
    case @text_kind
    when FORMAT_HTML
      html_to_html
    when FORMAT_MARKDOWN
      markdown_to_html
    end
  end

  def html_to_html
    @string
  end

  def markdown_to_html
    doc = _markdown_to_html_doc

    doc.css('pre code').each do |code_doc|
      code_text = code_doc.text
      klass = code_doc['class']
      if !klass.blank?
        pre = code_doc.parent
        div = Nokogiri::XML.fragment CodeRay.scan(code_text, klass).div(:css => :class)
        div.at_css('div.code')['class']="code #{klass}"
        pre.after div.to_xml
        pre.remove
      end
    end

    doc.css('a').each do |a_elm|
      a_elm['target']='_blank'
    end

    doc.css('img').each do |img_elm|
      img_elm['onload']='pie.feed_image_resize(jQuery(this))'
    end

    restr = doc.at_css('div').inner_html

    restr.gsub(AT_REG) do
      "<a href='/atmes/#{$1}'>@#{$1}</a>"
    end
  end

  #------------------------
  def to_text
    case @text_kind
    when FORMAT_HTML
      html_to_text
    when FORMAT_MARKDOWN
      markdown_to_text
    else
      html_to_text
    end
  end

  def html_to_text
    doc = Nokogiri::HTML.fragment("<div>#{@string}</div>")
    doc.text
  end

  def markdown_to_text
    doc = _markdown_to_html_doc
    doc.text
  end
  
end
