module SubMenuHelper

  def show_feed_menu?
    cname = controller.controller_name
    aname = controller.action_name
    return false if ['feed_revisions','index'] == [cname, aname]

    c1 = ( !['mindmaps','login'].include? sub_menu_name )
    c2 = ( ['feeds','user_logs','users','tags','notices','welcome'].include? sub_menu_name)
    return c1 && c2
  end

  def show_feed_menu_bg?
    cname = controller.controller_name
    aname = controller.action_name

    return false if ['users','show'] == [cname, aname]
    return false if ['users','logs'] == [cname, aname]
    return false if ['users','feeds'] == [cname, aname]
    return false if ['users','viewpoints'] == [cname, aname]

    return false if ['tags','show'] == [cname, aname]
    return false if ['tags','upload_logo'] == [cname, aname]

    return false if ['tag_detail_revisions','index'] == [cname, aname]

    return false if ['feeds','show'] == [cname, aname]
    return false if ['feeds','new'] == [cname, aname]
    return false if ['feeds','search'] == [cname, aname]
    return false if ['feed_revisions','index'] == [cname, aname]

    return show_feed_menu?
  end

  def sub_menu_name
    name = (controller.request.path.split('/') - [''])[0]
    return 'welcome' if !logged_in? && name.blank?
    return name
  rescue Exception => ex
    ''
  end

  def show_sub_menu
    render 'index/sub_menu',:name=>sub_menu_name
  end

  def _sub_menu_li_i_am_here?(name, path)
    if path.include? '/tags?'
      menu = 'tags'
      tab = path.split('=')[-1]
    else
      arr = path.split('/') - ['']
      menu = arr[-2]
      tab = arr[-1]
    end

    return current_page?(path) #|| tab == cookies["menu_#{menu}_tab".to_sym]
  end

  ######################

  def sub_menu_li(name, path, options={})
    link_str = link_to "<span>#{name}</span>",path
    o_klass=options[:class] || ''

    if _sub_menu_li_i_am_here?(name, path)
      klass = ["i-am-here",o_klass]*' '
    else
      klass = [o_klass]*' '
    end

    if(options[:first])
      link_str = "#{link_str}"
    else
      link_str = "#{link_str}"
    end

    return "<li class='#{klass}'>#{link_str}</li>"
  end

  def sub_menu_li_with_count(name, path, count)
    count_str = (count == 0) ? '':"<div class='count'>#{count}</div>"

    link_str = link_to "<span>#{name}</span>#{count_str}",path

    if _sub_menu_li_i_am_here?(name, path)
      return "<li class='with-count i-am-here'>#{link_str}</li>"
    else
      return "<li class='with-count'>#{link_str}</li>"
    end
  end

  #########################

  def sub_menu_small_li(name, path, options={})
    link_str = link_to "<span>#{name}</span>",path
    o_klass=options[:class] || ''

    if _sub_menu_li_i_am_here?(name, path)
      klass = ["i-am-here","s",o_klass]*' '
    else
      klass = ["s",o_klass]*' '
    end

    return "<li class='#{klass}'>#{link_str}</li>"
  end

  ###########################

  def feed_menu_li(name,path,tab,options={})
    is_here = (tab == sub_menu_name) || (tab == 'welcome' && sub_menu_name.blank?)

    o_klass = options[:class] || ''

    link_str = link_to "<span>#{name}</span>",path

    if is_here
      klass = [tab,"i-am-here",o_klass]*' '
      return "<li class='#{klass}'>#{link_str}</li>"
    else
      klass = [tab,o_klass]*' '
      return "<li class='#{klass}'>#{link_str}</li>"
    end
  end

  def feed_menu_li_with_count(name,path,tab,count,options={})
    is_here = (tab == sub_menu_name) || (tab == 'welcome' && sub_menu_name.blank?)

    o_klass = options[:class] || ''

    count_str = (count == 0) ? '':"<div class='count'>#{count}</div>"
    link_str = link_to "<span>#{name}</span>#{count_str}",path

    if is_here
      klass = [tab,"i-am-here",o_klass]*' '
      return "<li class='with-count #{klass}'>#{link_str}</li>"
    else
      klass = [tab,o_klass]*' '
      return "<li class='with-count #{klass}'>#{link_str}</li>"
    end
  end

end
