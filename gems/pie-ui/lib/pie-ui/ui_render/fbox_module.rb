module PieUi
  module FboxModule
    
    def fbox(operation,extra={},&block)
      if [:show,:close,:javascript].include?(operation)
        page << eval("_build_#{operation}_fbox_js(extra,&block)")
      end
      return self
    end

    def _build_show_fbox_js(extra)
      title = _build_title(extra)

      case extra
      when String
        _call_show_fbox(extra)
      else
        if extra[:partial]
          partial_str = _render_partial(extra)
          _call_show_fbox(title + partial_str)
        elsif extra[:content]
          str = extra[:content]
          _call_show_fbox(title + str)
        end
      end
    end

    def _build_title(extra)
      title = extra[:title]
      title.blank? ? "":"<h3 class='f_box'>#{title}</h3>"
    end

    def _call_show_fbox(string)
      json = string.to_json
      %~
        jQuery.facebox.settings.closeImage = '#{File.join UiService.site,'images/plugins/facebox/closelabel.gif'}';
        jQuery.facebox.settings.loadingImage = '#{File.join UiService.site,'images/plugins/facebox/closelabel.gif'}';

        //当fbox现在是显示状态时，再show的话，不重新loading
        if(jQuery('#facebox').length == 0 || jQuery('#facebox').css('display')=='none'){
          jQuery.facebox(#{json});
          jQuery('#facebox_overlay').unbind('click');
        }else{
          jQuery('#facebox .content').empty();
          jQuery.facebox.reveal(#{json});
        }
      ~
    end

    def _build_close_fbox_js(extra)
      %~
        jQuery(document).trigger('close.facebox');
      ~
    end
  end
end
