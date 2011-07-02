module PieUi
  module MindpinLayoutHelper
    # 用于其他子工程，引用公共ui
    def require_ui_css
      stylesheet_link_tag UiService.css_files
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
