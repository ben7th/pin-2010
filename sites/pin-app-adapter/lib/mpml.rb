class MPML
  def initialize(app,raw,request = nil)
    @app = app
    @raw = raw.gsub("\v",'')
    @request = request

    raw_mpml_str = "<mpml xmlns='http://www.w3.org/1999/xhtml' xmlns:mp='http://www.mindpin.com'>#{@raw}</mpml>"
    @doc = Nokogiri::XML(raw_mpml_str)
    
    @scripts = []
    @stylesheets = []
    @javascripts = []

    parse_layout
    parse_title
    
    parse_inline_script
    parse_mp_css
    parse_mp_js

    replace_url
    parse_hr
    
    parse_mplist
    parse_nav
    parse_finder
    
    parse_box
    parse_mpml_user_tags

    parse_accordion
  end

  def app_url
    callback_url = app.callback_url
    port = app.port
    port == 80 ? callback_url : "#{callback_url}:#{port}"
  end

  def app
    @app
  end

  def raw
    @raw
  end

  def doc
    @doc
  end

  def request
    @request
  end

  def html
    @doc.inner_html
  end

  def body
    @doc.css('mpml').inner_html
  end

  def layout
    @layout = false if @layout == 'false'
    @layout
  end

  def title
    @title
  end

  # js段落
  def scripts
    @scripts
  end

  # css文件引用
  def stylesheets
    @stylesheets
  end

  # js文件引用
  def javascripts
    @javascripts
  end

  # 内联js
  def parse_inline_script
    if layout != false
      doc.css('script').each do |el|
        if el.parent.name != 'textarea'
          src = el['src']
          if src.blank?
            @scripts<< el.to_s
            el.remove
          end
        end
      end
    end
  end

  def parse_mp_css
    doc.css('mp|css').each do |el|
      href = el['href']
      href = "http://#{app_url}#{href}" if href.at(0)=='/'
      @stylesheets << href
      el.remove
    end
    doc.css('link[rel=stylesheet]').each do |el|
      href = el['href']
      href = "http://#{app_url}#{href}" if href.at(0)=='/'
      @stylesheets << href
      el.remove
    end
  end

  def parse_mp_js
    doc.css('mp|js').each do |el|
      src = el['src']
      src = "http://#{app_url}#{src}" if src.at(0)=='/'
      @javascripts << src
      el.remove
    end
    doc.css('script').each do |el|
      src = el['src']
      if !src.blank?
        src = "http://#{app_url}#{src}" if src.at(0)=='/'
        @javascripts << src
        el.remove
      end
    end
  end

  def parse_layout
    elm = doc.css('mp|layout')
    @layout = elm.text
    elm.remove
  end

  def parse_title
    elm = doc.css('mp|title')
    @title = elm.text
    elm.remove
  end

  def parse_hr
    doc.css('mp|hr').each do |hr|
      rename hr,'div'
      hr['class'] = 'hr'
    end
  end

  def rename(node,name)
    @blank_namespace ||= doc.root.namespace
    node.namespace = @blank_namespace
    node.name = name
  end

  include MpmlList
  include MpmlBox
  include MpmlUrl
  include MpmlNav
  include MpmlUser
  include MpmlAccordion
end