module PieUi
  module MindpinLayoutHelper
    # 用于其他子工程，引用公共ui
    def require_ui_css
      stylesheet_link_tag UiService.css_files
    end

    def require_theme_css
      stylesheet_link_tag UiService.theme_css_file(@mindpin_layout.theme)
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

    def render_cellhead

      cellhead_path = @mindpin_layout.cellhead_path
      return '' if cellhead_path == false

      if cellhead_path.nil?
        cellhead_path = _get_special_partial_name('cellhead')
      end
      
      begin
        tail = @mindpin_layout.cellhead_tail || action_name
        return '' if @mindpin_layout.cellhead_tail == false
        render :partial=>"#{cellhead_path}_#{tail}"
      rescue ActionView::MissingTemplate => ex
        begin
          render :partial=>cellhead_path
        rescue
          render :partial=>base_layout_path('parts/cellhead.haml')
        end
      end
    end

    def render_actions
      actions_path = _get_special_partial_name('actions')
      begin
        render :partial=>actions_path
      rescue ActionView::MissingTemplate => ex
        ''
      end
    end

    def render_tabs
      tabs_path = @mindpin_layout.tabs_path
      return '' if tabs_path == false

      if tabs_path.nil?
        if ['new','edit','create','update'].include? action_name
          return ''
        else
          tabs_path = _get_special_partial_name('tabs')
        end
      end
      
      begin
        render :partial=>tabs_path
      rescue ActionView::MissingTemplate => ex
        ''
      end
    end

    def _get_special_partial_name(name)
      controller.class.name.underscore.sub('::','/').sub('_controller',"/#{name}")
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

    def rand_tips
      tips=[
        '您可以使用邮件参与工作空间中的话题讨论',
        '思维导图编辑器支持快捷键，您可以使用回车，空格，Ins，上下左右对导图进行操作',
        '思维导图编辑器的不少功能藏在节点的右键菜单里面',
        '思维导图可以很容易地导出成多种格式，在编辑器的右边就可以找到'
      ]
      num = rand tips.length
      tips[num]
    end

  end
end
