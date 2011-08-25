//发送范围选择
pie.load(function(){
  var selector_elm = jQuery('.field.sendto-select-widget .sendto-selector');
  var sendtos_elm = jQuery('.field.sendto-select-widget .sendtos');
  var sendto_hid_elm = jQuery('.field.sendto-select-widget .sendto-hid');
  var sendto_add_elm = jQuery('.field.sendto-select-widget .sendto-ipter .add');
  var prefix = '.field.sendto-select-widget '

  if(selector_elm.length > 0 && sendtos_elm.length > 0 && sendto_hid_elm.length > 0){

    sendto_add_elm.live('click',function(){
      var ipter_elm = jQuery(this).closest('.sendto-ipter');
      var offset = ipter_elm.offset();
      var height = ipter_elm.outerHeight();
      selector_elm.css('left',offset.left).css('top',offset.top + height - 1).fadeIn(200);
    })

    jQuery(document).bind('click.sendto_selector',function(evt){
      var target = evt.target;

      if(selector_elm[0] == target || jQuery.contains(selector_elm[0],target)){
        return;
      }

      if(jQuery.contains(sendto_add_elm[0],target) || sendto_add_elm[0] == target){
        return;
      }
      selector_elm.hide();
    });

    var all_public_grp_dom_str =
      "<div class='ch all-public'>"+
        "<span class='icon'></span><span>完全公开</span><span class='close'>x</span>"+
      "</div>";
    var all_followings_grp_dom_str =
      "<div class='ch all-followings'>"+
        "<span class='icon'></span><span>所有联系人</span><span class='close'>x</span>"+
      "</div>";

    var a_ch_dom = function(id,name){
      str = "<div class='ch a-ch' data-id='"+id+"'>"+
        "<span class='icon'></span><span>"+name+"</span><span class='close'>x</span>"+
      "</div>"
      return jQuery(str);
    }

    var set_sendto_valstr = function(){
      var valstr = [];
      sendtos_elm.find('.ch').each(function(){
        var elm = jQuery(this);
        if(elm.hasClass('all-public')){ valstr.push('public') }
        if(elm.hasClass('all-followings')){ valstr.push('followings') }
        if(elm.hasClass('a-ch')){ valstr.push('ch-'+elm.attr('data-id')) }
      })

      valstr = valstr.join(',')
      sendto_hid_elm.val(valstr);
    }

    set_sendto_valstr();

    jQuery('.field.sendto-select-widget .sendtos .ch.all-public').tipsy({
      gravity:'s',
      fallback:'<div class="bold">完全公开</div><div>公开地发送给关注你的所有人</div>',
      html:true,
      live:true
    })

    jQuery('.field.sendto-select-widget .sendtos .ch.all-followings').tipsy({
      gravity:'s',
      fallback:'<div class="bold">所有联系人</div><div>发送给你关注的所有人（你的联系人）</div>',
      html:true,
      live:true
    })

    jQuery('.field.sendto-select-widget .sendtos .ch.a-ch').tipsy({
      gravity:'s',
      title:function(){
        var elm = jQuery(this);
        var name = jQuery(elm.find('span')[1]).html();
        return '<div class="bold">'+name+'</div><div>发送给这个频道中的联系人</div>'
      },
      html:true,
      live:true
    })

    // 选择“完全公开”
    jQuery(document).delegate(prefix + '.groups .all-public','click',function(){
      var elm = jQuery(this);
      if(elm.hasClass('lock')){return;}

      var ch_elm = jQuery(all_public_grp_dom_str);
      selector_elm.hide();

      if(sendtos_elm.find('.ch.all-public').length > 0){return;}

      //清除全部选项
      sendtos_elm.find('.ch').remove();
      selector_elm.find('.it').removeClass('lock');
      elm.addClass('lock');
      sendtos_elm.append(ch_elm);
      //赋值
      set_sendto_valstr();
    })

    // 选择“所有联系人”
    jQuery(document).delegate(prefix + '.groups .all-followings','click',function(){
      var elm = jQuery(this);
      if(elm.hasClass('lock')){return;}

      var ch_elm = jQuery(all_followings_grp_dom_str);
      selector_elm.hide();

      if(sendtos_elm.find('.ch.all-followings').length > 0){return;}

      //清除全部选项
      sendtos_elm.find('.ch').remove();
      selector_elm.find('.it').removeClass('lock');
      elm.addClass('lock');
      sendtos_elm.append(ch_elm);
      //赋值
      set_sendto_valstr();
    })

    // 选择“某频道”
    jQuery(document).delegate(prefix + '.channels .ch','click',function(){
      var elm = jQuery(this);
      if(elm.hasClass('lock')){return;}

      var id = elm.attr('data-id');
      var name = elm.attr('data-name');

      var ch_elm = a_ch_dom(id,name);
      selector_elm.hide();

      if(sendtos_elm.find('.ch.a-ch[data-id='+id+']').length > 0){
        return;
      }

      //清除groups中的选项
      sendtos_elm.find('.ch.all-public, .ch.all-followings').remove();
      selector_elm.find('.groups .it').removeClass('lock');
      elm.addClass('lock');
      sendtos_elm.append(ch_elm);
      //赋值
      set_sendto_valstr();
    });

    // 取消某一项选择
    jQuery(document).delegate(prefix + '.sendtos .ch .close','click',function(){
      var elm = jQuery(this);
      var ch_elm = elm.closest('.ch');
      ch_elm.remove();

      if(ch_elm.hasClass('all-public')){
        selector_elm.find('.groups .all-public').removeClass('lock');
      }

      if(ch_elm.hasClass('all-followings')){
        selector_elm.find('.groups .all-followings').removeClass('lock');
      }

      if(ch_elm.hasClass('a-ch')){
        var id = ch_elm.attr('data-id');
        selector_elm.find('.ch[data-id='+id+']').removeClass('lock');
      }

      jQuery('.tipsy').remove();

      //赋值
      set_sendto_valstr();
    });

  }
})