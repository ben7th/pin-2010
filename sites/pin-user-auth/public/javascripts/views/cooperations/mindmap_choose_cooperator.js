pie.load(function(){
  var ccpanel_elm = jQuery('.channel-member-choose-panel');
  var selected_users_elm = ccpanel_elm.find('.selected-users');

  jQuery('.cooperator-config .icon').live('click',function(){
    if(ccpanel_elm.attr("data-show") != "true"){
      ccpanel_elm.attr("data-show","true")
      show_ccpanel();
    }else{
      ccpanel_elm.attr("data-show",null)
      close_ccpanel();
    }
  });
  
  ccpanel_elm.find('.fo-u').live("click",function(){
    var elm = jQuery(this);
    if(elm.hasClass("added")) return;
    if(elm.hasClass("selected")){
      fo_u_unselect(elm);
    }else{
      fo_u_select(elm);
    }
  });
  
  selected_users_elm.find('.u .icon').live("click",function(){
    var u_elm = jQuery(this).closest('.u');
    var user_id = u_elm.attr('data-user-id');
    var elm = ccpanel_elm.find('.fo-u[data-user-id='+user_id+']');
    fo_u_unselect(elm);
  });

  ccpanel_elm.find('.btns .editable-cancel').live('click',function(){
    close_ccpanel();
  });

  ccpanel_elm.find('.btns .editable-submit').live('click',function(){
    var add_cooperator_ids = [];
    selected_users_elm.find('.u').each(function(){
      add_cooperator_ids.push(jQuery(this).attr('data-user-id'));
    });

    var mindmap_id = ccpanel_elm.closest(".avatars").attr("data-m-id")
    jQuery.ajax({
      url : "/cooperate/"+mindmap_id+"/add_cooperator",
      data : "user_ids="+add_cooperator_ids.join(","),
      type : "POST",
      beforeSend:function(){
        pie.show_loading_bar();
      },
      success : function(res){
        close_ccpanel();
        var ava_elm = jQuery(res);
        jQuery(".avatars").find('.cooperator-config').before(ava_elm);
      },
      complete:function(){
        pie.hide_loading_bar();
      }
    });
  });


  ccpanel_elm.find('.rmvico').live('click',function(evt){
    var elm = jQuery(this);
    setTimeout(function(){
      if(confirm('确定吗？')){
        var fo_elm = elm.closest('.fo-u')
        var user_id = fo_elm.attr('data-user-id');
        var ava_elm = jQuery('.avatars .avatar[data-id='+user_id+']');

        var mindmap_id = ccpanel_elm.closest(".avatars").attr("data-m-id")
        jQuery.ajax({
          url  : "/cooperate/"+mindmap_id+"/remove_cooperator",
          data : 'user_id='+user_id,
          type : 'DELETE',
          success : function(){
            fo_elm.removeClass('added');
            ava_elm.remove();
          }
        })
      }
    },1);
  })

  function fo_u_select(elm){
    elm.addClass('selected');
    var user_id = elm.attr('data-user-id');
    var user_name = elm.find('.name').html();
    var u_elm = jQuery('<div class="u shadow moredarkbg" data-user-id="'+user_id+'">'+user_name+'<div class="icon csshov"></div></div>');
    selected_users_elm.append(u_elm);
  }

  function fo_u_unselect(elm){
    elm.removeClass('selected');
    var user_id = elm.attr('data-user-id');
    var u_elm = selected_users_elm.find('.u[data-user-id='+user_id+']');
    u_elm.remove();
  }

  function show_ccpanel(){
    // 清空已选择区域
    selected_users_elm.html("");
    ccpanel_elm.find('.fo-u.selected').removeClass('selected');

    var cooperator_ids = [];
    ccpanel_elm.closest(".avatars").find(".avatar.cooperator").each(function(){
      cooperator_ids.push(jQuery(this).attr("data-id"));
    });
    
    ccpanel_elm.find(".fo-u").each(function(){
      var f = jQuery(this);
      f.removeClass("added");
      if(cooperator_ids.include(f.attr("data-user-id"))){
        f.addClass("added");
      }
    });

    ccpanel_elm.show();
  }

  function close_ccpanel(){
    ccpanel_elm.hide();
    ccpanel_elm.attr("data-show",null)
  }
});

