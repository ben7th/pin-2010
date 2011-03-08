pie.load(function(){

  var none_str = '无频道';

  var contacts_list_c_elm = jQuery('.contacts-list .c-channel .c');
  var channel_form_elm = jQuery('.contacts-list').next('.channel-form');
  var channel_form_inputer_elm = channel_form_elm.find('input.ch-inputer');

  var truncate = function(names){
    return pie.truncate_u(names,15).gsub('...','…');
  }

  var hide_form_inputer = function(){
    channel_form_elm.find('.cr').show();
    channel_form_elm.find('.cf').hide();
  }

  var show_form_inputer = function(){
    channel_form_elm.find('.cr').hide();
    channel_form_elm.find('.cf').show();
    channel_form_inputer_elm.val('');
  }

  var position_and_show_form = function(elm){
    var offset = elm.offset();
    channel_form_elm.css('top',offset.top + elm.outerHeight() + 2);
    channel_form_elm.css('left',offset.left);
    channel_form_elm.show();
  }

  var get_channel_ids = function(elm){
    return elm.attr('data-channel-ids').split(',');
  }

  var get_channel_names = function(elm){
    return elm.attr('data-names').split(', ');
  }

  var append_channel_form_line = function(channel_id, channel_name){
    var html =
      '<div data-channel-id="'+channel_id+'" class="c">'+
        '<div class="icon"></div>'+
        '<div class="name">'+channel_name+'</div>'+
      '</div>'
    channel_form_elm.find('.channels').append(html);
  }

  var append_channel_tab = function(channel_id, channel_name){
    var tab_html =
      '<li>'+
        '<a href="'+pie.pin_url_for('pin-user-auth','/'+pie.current_user_id+'/followings?channel='+channel_id)+'">'+channel_name+'</a>'+
      '</li>'
    jQuery('.channel-panel ul.channels').append(tab_html);
  }


  //初始化列表内每个人的频道名
  contacts_list_c_elm.each(function(){
    var elm = jQuery(this);
    var names = elm.attr('data-names');
    if(jQuery.string(names).blank()) names = none_str;
    elm.find('.cn').html(truncate(names));
  });

  //点开频道设置表单，把该用户所属的频道打上勾
  contacts_list_c_elm.bind('click',function(){
    var elm = jQuery(this);
    var f_uid = channel_form_elm.attr('data-user-id');
    var e_uid = elm.attr('data-user-id');

    if(channel_form_elm.css('display') == 'none' || f_uid != e_uid){

      position_and_show_form(elm);
      hide_form_inputer();
      channel_form_elm.attr('data-user-id',e_uid);

      channel_form_elm.find('.c').each(function(){
        var c = jQuery(this);
        var id = c.attr('data-channel-id');
        if(get_channel_ids(elm).include(id)){
          c.addClass('checked');
        }else{
          c.removeClass('checked');
        }
      });
    }else{
      channel_form_elm.hide();
    }
  });

  //注册频道编分配表单关闭事件
  jQuery(document).bind('click',function(evt){
    var elm = jQuery(evt.target);
    if(elm.parents('.channel-form').length == 0 && elm.parents('.c-channel').length == 0){
      channel_form_elm.hide();
    }
  })

  //显示创建频道输入器
  channel_form_elm.find('.cr a').bind('click',show_form_inputer);

  //创建新频道
  channel_form_elm.find('button.editable-submit').bind('click',function(evt){
    var inputer_value = channel_form_inputer_elm.val();

    if(jQuery.string(inputer_value).blank()){
      pie.inputflash(channel_form_inputer_elm);
      return;
    }

    jQuery.ajax({
      type    : 'POST',
      url     : '/channels',
      data    : 'name=' + inputer_value,
      success : function(res){
        var channel_id   = res['channel']['id'];
        var channel_name = res['channel']['name'];
        append_channel_form_line(channel_id, channel_name);
        append_channel_tab(channel_id, channel_name);
        hide_form_inputer();
      }
    })
  });

  //注册取消创建频道的按钮事件
  channel_form_elm.find('button.editable-cancel').bind('click',hide_form_inputer);

  var add_channel_to_user_c_elm = function(user_c_elm, channel_id, channel_name){
    //改变NAME
    var old_names = user_c_elm.attr('data-names');
    var new_names;
    if(jQuery.string(old_names).blank()){
      new_names = channel_name;
    }else{
      var tmp_n_arr = old_names.split(', ');
      tmp_n_arr.push(channel_name);
      new_names = tmp_n_arr.join(', ');
    }
    user_c_elm.attr('data-names',new_names);
    user_c_elm.find('.cn').html(truncate(new_names));

    //改变ID
    var old_ids = user_c_elm.attr('data-channel-ids');
    var new_ids;
    if(jQuery.string(old_ids).blank()){
      new_ids = channel_id;
    }else{
      var tmp_i_arr = old_ids.split(',');
      tmp_i_arr.push(channel_id);
      new_ids = tmp_i_arr.join(',');
    }
    user_c_elm.attr('data-channel-ids',new_ids);
  }

  var remove_channel_from_user_c_elm = function(user_c_elm, channel_id, channel_name){
    //改变NAME
    var old_names = user_c_elm.attr('data-names');
    var new_names = old_names.split(', ').without(channel_name).join(', ');
    user_c_elm.attr('data-names',new_names);
    var cn_elm = user_c_elm.find('.cn')
    if(jQuery.string(new_names).blank()){
      cn_elm.html(none_str);
    }else{
      cn_elm.html(truncate(new_names));
    }

    //改变ID
    var new_ids = get_channel_ids(user_c_elm).without(channel_id).join(',');
    user_c_elm.attr('data-channel-ids',new_ids);
  }

  //注册将user加入频道的事件
  jQuery('.channel-form .channels .c').live('click',function(evt){
    var elm = jQuery(this);
    var channel_id   = elm.attr('data-channel-id');
    var channel_name = elm.find('.name').html();
    var user_id      = channel_form_elm.attr('data-user-id');
    
    var user_c_elm  = jQuery('li#user_'+user_id).find('.c-channel .c');

    if(elm.hasClass('checked')){
      elm.removeClass('checked');
      jQuery.ajax({
        type    : 'PUT',
        url     : '/channels/'+channel_id+'/remove',
        data    : 'user_id='+user_id,
        success : function(){
          remove_channel_from_user_c_elm(user_c_elm, channel_id, channel_name);
        }
      })
    }else{
      //加入user到频道
      elm.addClass('checked');
      jQuery.ajax({
        type    : 'PUT',
        url     : '/channels/'+channel_id+'/add',
        data    : 'user_id='+user_id,
        success : function(){
          add_channel_to_user_c_elm(user_c_elm,channel_id,channel_name);
        }
      })
    }
  })
  
});

pie.load(function(){
  var form_elm = jQuery('.channel-op .rename-channel-form');

  var truncate = function(names){
    return pie.truncate_u(names,15).gsub('...','…');
  }

  var position_and_show_form = function(elm){
    var position = elm.position();
    form_elm.css('top',position.top + elm.outerHeight() + 3);
    form_elm.css('left',position.left - 5);
    form_elm.find('input.ch-inputer').val('');
    form_elm.show();
  }

  jQuery('.channel-op a.rename-channel').bind('click',function(){
    if(form_elm.css('display') == 'none'){
      position_and_show_form(jQuery(this));
    }else{
      form_elm.hide();
    }
  });

  //注册表单关闭事件
  jQuery(document).bind('click',function(evt){
    var elm = jQuery(evt.target);
    if(elm.parents('.rename-channel-form').length == 0 && elm.parents('.rename-channel').length == 0){
      form_elm.hide();
    }
  })

  form_elm.find('.editable-cancel').click(function(){
    form_elm.hide();
  })

  form_elm.find('.editable-submit').click(function(){
    var new_name = form_elm.find('input.ch-inputer').val();
    if(jQuery.string(new_name).blank()){
      pie.inputflash(form_elm.find('input.ch-inputer'));
      return;
    }

    var channel_id = form_elm.attr('data-channel-id');
    var old_name = jQuery('.channel-panel .current a').html();
    jQuery.ajax({
      type    : 'PUT',
      url     : '/channels/'+channel_id,
      data    : 'name=' + new_name,
      success : function(res){
        form_elm.hide();

        //页签上
        jQuery('.channel-panel .current a').html(new_name);

        //每个用户的显示区域
        jQuery('.mplist.users .user.mpli .c-channel .c').each(function(){
          var elm = jQuery(this);
          var old_names_arr = elm.attr('data-names').split(', ');

          var narr = old_names_arr.without(old_name);
          narr.push(new_name)

          var new_names = narr.join(', ');
          elm.attr('data-names',new_names);
          elm.find('.cn').html(truncate(new_names));
        });

        //表单里
        jQuery('.contacts-list').next('.channel-form').find('.channels .c .name').each(function(){
          var elm = jQuery(this);
          if(elm.html() == old_name) elm.html(new_name);
        })
      }
    })
  });

});