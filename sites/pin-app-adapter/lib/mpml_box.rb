module MpmlBox
  def parse_box
    _parse_box
  end

  def _parse_box
    doc.css('mp|box').each do |box|
      box['class'] = box['class']||'' +' '
      rename box,'div'

      title = box.css('mp|box-title')[0]
      rename title,'h3'
      title['class'] = 'f_box'

      content = box.css('mp|box-content')[0]
      rename content,'div'

      box.css('mp|box-button').each do |button|
        case button['ajax']
        when 'true'
          _parse_ajax_box_form(button)
        when 'iframe'
          _parse_ajax_iframe_box_form(button)
        else
          _parse_common_box_form(button)
        end
        
        button.remove
      end
      
      _parse_show_box_link(box)

      box.remove
    end
  end

  def _build_fbox_form_button(button)
    value = button['value']
    button.after %~
      <span class='ui-button-span'>
        <button type='submit' class='ui-button'>
          #{value}
        </button>
      </span>
    ~
  end

  # 普通的表单，普通的提交
  def _parse_common_box_form(button)
    _build_fbox_form_button(button)

    form_id = button['form_id'].to_json
    onclick = "$(#{form_id}).submit();return false;"

    button.next.at('button')['onclick'] = onclick.gsub("\n",'')
  end

  def _parse_ajax_iframe_box_form(button)
    _build_fbox_form_button(button)
    
    form = doc.at_css("##{button['form_id']}")
    form['action'] = form['action'].
      add_url_param('iframe_ajax','true').
      add_url_param('mplist_json','true').
      add_url_param('list_id',button['ajax_list_id']).
      add_url_param('onsuccess',button['onsuccess'])
    form['target'] = 'upload_frame'

    form_id = button['form_id'].to_json
    onclick = "$(#{form_id}).submit();return false;"

    button.next.at('button')['onclick'] = onclick.gsub("\n",'')
  end

  def _parse_ajax_box_form(button)
    
    _build_fbox_form_button(button)

    url = doc.at_css("##{button['form_id']}")['action']
    close_box = (button['close_box'] == 'true')
    onsuccess = button['onsuccess']
    form_id = button['form_id'].to_json
    ajax_list_id = button['ajax_list_id'].to_json

    onclick = %~
      new Ajax.Request("#{url}",{
        parameters:Form.serialize(#{form_id})+"&mplist_json=true",
        onSuccess:function(r){
          pie.mplist.deal_app_json(r.responseText,"app_#{app.name}",#{ajax_list_id});
          #{close_box ? 'close_fbox();':''}
          try{#{onsuccess}(r.responseText.evalJSON())}catch(e){}
        }
      });
    ~

    begin
      button.next.at('button')['onclick'] = onclick.gsub("\n",'')
    rescue Exception => ex
      button.remove
    end

  end

  def _parse_show_box_link(box)
    box_id = box['id']

    doc.css("mp|show-box[box_id=#{box_id}]").each do |link|
      html_json = box.inner_html.to_json
      rename link,'a'
      link['href'] = "javascript:show_fbox(#{html_json});"
      link.delete 'box_id'
    end
  end
  
end
