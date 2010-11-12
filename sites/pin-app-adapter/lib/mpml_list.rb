module MpmlList
  def parse_mplist
    doc.css('mp|list').each do |list|
      list.css('mp|li').each do |li|
        rename li,'li'
        li['id'] = "app_#{app.name}_#{li['id']}"
        klass = (li['class']||'').split(' ')
        li['class'] = [list['for'],klass].flatten.uniq*' '
      end
      rename list,'ul'

      mouseoverableclass =_mouseoverableclass(list)
      selectableclass = _selectableclass(list)
      forclass = _forclass(list)

      list['class'] = ["mplist",forclass,mouseoverableclass,selectableclass,list['class']]*' '
      
    end

    _parse_mp_li_actions
  end

  def _forclass(list)
    re = list['for']
    list.delete 'for'
    re
  end

  def _mouseoverableclass(list)
    re = (list['mouseoverable']) == 'true' ? 'mouseoverable':''
    list.delete 'mouseoverable'
    re
  end

  def _selectableclass(list)
    re = (list['selectable']) == 'true' ? 'selectable':''
    list.delete 'selectable'
    re
  end

  def _parse_mp_li_actions
    _parse_mp_li_remove
  end

  def _parse_mp_li_remove
    doc.css('mp|li-remove').each do |mlr|
      url = "/app/#{app.name}#{mlr['remote_url']}"
      li_id = "app_#{app.name}_#{mlr['li_id']}"
      confirm = mlr['confirm']
      if confirm.blank?
        mlr.before %~
          <a href='#' onclick="new Ajax.Request('#{url}',{method:'delete',onSuccess:function(){pie.mplist.remove_li('#{li_id}')}});return false;">#{mlr.inner_html}</a>
        ~
      else
        mlr.before %~
          <a href='#' onclick="if(confirm('#{confirm}')){ new Ajax.Request('#{url}',{method:'delete',onSuccess:function(){pie.mplist.remove_li('#{li_id}')}}); }; return false;">#{mlr.inner_html}</a>
        ~
      end
      mlr.remove
    end
  end
end
