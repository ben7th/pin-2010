module PieUi
  module MindpinLayoutHelper
    # 用于其他子工程，引用公共ui
    def require_ui_css
      stylesheet_link_tag UiService.css_files
    end

    def require_theme_css
      stylesheet_link_tag UiService.theme_css_file
    end

    def require_lib_js
      javascript_include_tag UiService.js_lib_files
    end

    def require_mindpin_js
      javascript_include_tag UiService.js_files
    end


    # 获取页面布局的container样式名
    def container_classname
      @get_container_classname ||= _layout_classname('container')
    end

    def head_classname
      @mindpin_layout.head_class || ''
    end

    # 获取页面布局的grid样式名
    def grid_classname
      @get_grid_classname ||= _layout_classname('grid')
    end

    def _layout_classname(prefix)
      return "#{prefix}_#{@mindpin_layout.grid}" if @mindpin_layout.grid
      return ''
    end

    # layout内部修饰模板
    def yield_partial_html
      yield_partial = @mindpin_layout.yield_partial
      
      if yield_partial.nil?
        return render(:partial=>base_layout_path("yield/yield_only.haml"))
      end

      begin
        render(:partial=>base_layout_path("yield/#{yield_partial}.haml"))
      rescue ActionView::MissingTemplate => ex
        render(:partial=>"/layouts/yield/#{yield_partial}")
      end

    end

    def render_nav
      if logged_in?
        begin
          render :partial=>'/layouts/user_nav_box'
        rescue Exception => ex
          render :partial=>base_layout_path('parts/user_nav_box.haml')
        end
        return
      end

      begin
        render :partial=>'/layouts/user_nav_box_not_logged_in'
      rescue Exception => ex
        render :partial=>base_layout_path('parts/user_nav_box_not_logged_in.haml')
      end
    end

    def render_actions
      actions_path = controller.class.name.downcase.sub('::','/').sub('controller','/actions')
      begin
        render :partial=>actions_path
      rescue
        ''
      end
    end

    def render_tabs
      tabs_path = controller.class.name.downcase.sub('::','/').sub('controller','/tabs')
      begin
        render :partial=>tabs_path
      rescue ActionView::MissingTemplate => ex
        ''
      end
    end

    def tabs_link_to(name, options = {}, html_options = {}, &block)
      return link_to(name, options, html_options.merge(:class=>'selected'), &block) if current_page?(options)
      link_to(name, options, html_options, &block)
    end

    def welcome_string
      if logged_in?
        @mindpin_layout.welcome_string || @welcome_string || current_user.name
      end
    end

  #  # 获取当前页面显示主题字符串，如果没有默认是 'sapphire'
  #  def get_user_theme_str
  #    if @mindpin_layout.theme.blank?
  #      user = current_user
  #
  #      # 个人主页特殊处理
  #      if [controller_name,action_name] == ["users","show"]
  #        user = User.find(params[:id])
  #      end
  #
  #      return "sapphire" if user.blank?
  #
  #      user.create_preference if user.preference.blank?
  #      theme = user.preference.theme
  #      theme = "sapphire" if theme.blank?
  #      return theme
  #    else
  #      @mindpin_layout.theme
  #    end
  #  end

  end
end
