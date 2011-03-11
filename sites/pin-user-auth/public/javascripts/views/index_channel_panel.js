/* 
 * 用于首页显示的频道页签
 */

pie.load(function(){
  var setting_elm = jQuery('.channel-panel .setting');

  jQuery('.channel-panel ul.channels .more').bind('click',function(){
    var elm = jQuery(this);
    var setting_elm = elm.closest('.channel-panel').find('.setting');
    var o = elm.offset();
    setting_elm.css('left',o.left).css('top',o.top + elm.outerHeight());
    setting_elm.show();
  })

  setting_elm.find('a').click(function(){
    setTimeout(function(){
      setting_elm.hide();
    },1000)
  })

  jQuery(document).click(function(evt){
    var elm = jQuery(evt.target);
    if(elm.parents('.more').length == 0 && elm.parents('.setting').length == 0){
      setting_elm.hide();
    }
  })

  var btn_clickable = function(elm){
    var up_elm = jQuery('#facebox .ch-list .ops .up');
    var down_elm = jQuery('#facebox .ch-list .ops .down');

    up_elm.removeClass('clickable');
    down_elm.removeClass('clickable');

    var next = elm.next('.ch');
    var prev = elm.prev('.ch');

    if(prev.length>0){
      up_elm.addClass('clickable');
    }

    if(next.length>0){
      down_elm.addClass('clickable');
    }
  }

  var get_data_ids = function(){
    var arr = [];
    jQuery('#facebox .ch-list .ch').each(function(){
      arr.push(jQuery(this).attr('data-id'));
    })
    return arr;
  }

  jQuery('#facebox .ch-list .ch').live('click',function(){
    var elm = jQuery(this);
    jQuery('#facebox .ch-list .ch').removeClass('selected');
    elm.addClass('selected')

    btn_clickable(elm);
  })

  jQuery('#facebox .ch-list .up.clickable').live('click',function(){
    var selected = jQuery('#facebox .ch-list .ch.selected');
    var prev = selected.prev();
    prev.before(selected);
    btn_clickable(selected);

    var id = selected.attr('data-id');
    var tab = jQuery('#facebox .ch-list .preview .chtabs .tab[data-id='+id+']');
    tab.prev().before(tab);
  })
  
  jQuery('#facebox .ch-list .down.clickable').live('click',function(){
    var selected = jQuery('#facebox .ch-list .ch.selected');
    var next = selected.next();
    next.after(selected);
    btn_clickable(selected);

    var id = selected.attr('data-id');
    var tab = jQuery('#facebox .ch-list .preview .chtabs .tab[data-id='+id+']');
    tab.next().after(tab);
  })

  jQuery('#facebox .ch-list button.editable-submit').live('click',function(){
    var ids = get_data_ids();
    jQuery('#facebox .ch-list .aj-loading').show();
    jQuery.ajax({
      type    : 'PUT',
      url     : '/channels/sort',
      data    : 'ids=' + ids.join(','),
      success : function(res){
        document.location.reload();
      }
    })
  })

  jQuery('#facebox .ch-list button.editable-cancel').live('click',function(){
    jQuery.facebox.close();
  })
})


