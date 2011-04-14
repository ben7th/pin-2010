pie.load(function(){
  var ccpanel_elm = jQuery('.channel-member-choose-panel');
  var selected_users_elm = ccpanel_elm.find('.selected-users');

  jQuery('.mplist.channels li.mpli .config').live('click',function(){
    selected_users_elm.html('');
    ccpanel_elm.find('.fo-u.selected').removeClass('selected');

    var avatars_elm = jQuery(this).closest('.avatars');
    var channel_id = avatars_elm.attr('data-c-id');

    if(ccpanel_elm.attr('data-c-id') == channel_id){
      close_ccpanel();
    }else{
      var added_ids = [];
      avatars_elm.find('.avatar').each(function(){
        added_ids.push(jQuery(this).attr('data-id'))
      })

      ccpanel_elm.find('.fo-u').each(function(){
        var f = jQuery(this);
        f.removeClass('added');
        if(added_ids.include(f.attr('data-user-id'))){
          f.addClass('added');
        }
      })

      var o = avatars_elm.offset();
      ccpanel_elm.attr('data-c-id',channel_id);
      ccpanel_elm.css('left',o.left-2).css('top',o.top+avatars_elm.outerHeight()+2);
      ccpanel_elm.show();
    }
  })

  ccpanel_elm.find('.fo-u').live('click',function(){
    var elm = jQuery(this);
    if(elm.hasClass('added')) return;
    if(elm.hasClass('selected')){
      unselect(elm);
    }else{
      select(elm);
    }
  })

  var select = function(elm){
    elm.addClass('selected');
    var user_id = elm.attr('data-user-id');
    var user_name = elm.find('.name').html();
    var u_elm = jQuery('<div class="u shadow moredarkbg" data-user-id="'+user_id+'">'+user_name+'<div class="icon csshov"></div></div>');
    selected_users_elm.append(u_elm);
  }

  var unselect = function(elm){
    elm.removeClass('selected');
    var user_id = elm.attr('data-user-id');
    var user_name = elm.find('.name').html();
    var u_elm = jQuery('.u[data-user-id='+user_id+']');
    u_elm.remove();
  }

  selected_users_elm.find('.u .icon').live('click',function(){
    var u_elm = jQuery(this).closest('.u');
    var user_id = u_elm.attr('data-user-id');
    var elm = ccpanel_elm.find('.fo-u[data-user-id='+user_id+']');
    pie.log(elm)
    unselect(elm);
  });

  var close_ccpanel = function(){
    selected_users_elm.html('');
    ccpanel_elm.attr('data-c-id',null);
    ccpanel_elm.find('.fo-u.selected').removeClass('selected');
    ccpanel_elm.hide();
  };

  ccpanel_elm.find('.btns .editable-cancel').live('click',function(){
    close_ccpanel();
  });

  ccpanel_elm.find('.btns .editable-submit').live('click',function(){
    var channel_id = ccpanel_elm.attr('data-c-id');
    if(channel_id){
      var user_ids = [];
      selected_users_elm.find('.u').each(function(){
        user_ids.push(jQuery(this).attr('data-user-id'));
      });
      
      jQuery.ajax({
        url  : '/channels/'+channel_id+'/add_users',
        data : 'user_ids='+user_ids.join(','),
        type : 'POST',
        success : function(res){
          close_ccpanel();
          var ava_elm = jQuery(res);
          jQuery('.avatars[data-c-id='+channel_id+']').find('.config').before(ava_elm);
        }
      })
    }
  });

  //绑定 移除用户 事件
  ccpanel_elm.find('.rmvico').live('click',function(evt){
    var elm = jQuery(this);
    setTimeout(function(){
      if(confirm('确定吗？')){
        var fo_elm = elm.closest('.fo-u')
        var user_id = fo_elm.attr('data-user-id');
        var channel_id = ccpanel_elm.attr('data-c-id');
        var ava_elm = jQuery('.avatars[data-c-id='+channel_id+'] .avatar[data-id='+user_id+']');

        jQuery.ajax({
          url  : '/channels/'+channel_id+'/remove',
          data : 'user_id='+user_id,
          type : 'PUT',
          success : function(){
            fo_elm.removeClass('added');
            ava_elm.remove();
          }
        })
      }
    },1);
  })

})