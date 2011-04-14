//发送feed
pie.load(function(){
  jQuery('.feed-form .ipter .feed-content').val('');

  jQuery('.feed-form .subm .subbtn').live('click',function(){
    var inputer_elm = jQuery('.feed-form .ipter .feed-content');
    var content = inputer_elm.val();

    var channel_id = jQuery('.feed-form .ipter .channel-id').val();

    var data;
    if(channel_id){
      data = 'content='+encodeURIComponent(content)+'&channel_id='+channel_id;
    }else{
      data = 'content='+encodeURIComponent(content);
    }

    pie.log(content)
    if(jQuery.string(content).blank()){
      pie.inputflash(inputer_elm);
      return;
    }

    jQuery.ajax({
      url  : pie.pin_url_for('pin-user-auth','/newsfeed/do_say'),
      type : 'post',
      data : data,
      success : function(res){
        //创建成功
        inputer_elm.val('');
        var dom_elm = jQuery(res);
        var lis = dom_elm.find('li');
        jQuery('#mplist_feeds').prepend(lis);
        lis.hide().slideDown(400);
      }
    });
  });
})

pie.load(function(){
  //标记
  jQuery('.newsfeed .feed .ops .fav').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.f');
    var id = f_elm.attr('data-id');

    var is_on = elm.hasClass('on');

    if(is_on){
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/unfav'),
        type :'delete',
        success : function(res){
          elm.removeClass('on').addClass('off');
        }
      });
    }else{
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/fav'),
        type :'post',
        success : function(res){
          elm.removeClass('off').addClass('on');
        }
      });
    }
  });
});

pie.load(function(){
  //回应
  jQuery('.newsfeed .feed .ops .echo').live('click',function(){
    var elm = jQuery(this);
    var feed_f_elm = elm.closest('.f');
    var id = feed_f_elm.attr('data-id');
    
    if(feed_f_elm.find('.comments').length > 0){
      feed_f_elm.find('.comments').remove();
      return;
    }

    var cms_elm = jQuery('<div class="comments darkbg loading"></div>')
    feed_f_elm.append(cms_elm);

    jQuery.ajax({
      url  : "/feeds/"+id+"/aj_comments",
      type : 'GET',
      success : function(res){
        var res_elm = jQuery(res);
        cms_elm.append(res_elm).removeClass('loading');
      }
    })
  })

  jQuery('.feed-echo-form .send-to').live('click',function(){
    jQuery(this).toggleClass('checked');
  })

  jQuery('.feed-echo-form button.editable-submit').live('click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('.feed-echo-form');
    var reply_to_id = form_elm.attr('data-feed-id');

    var content = form_elm.find('textarea').val();
    var send_new_feed = form_elm.find('.send-to').hasClass('checked');

    jQuery.ajax({
      url  : '/feeds/reply_to',
      type : 'POST',
      data : 'reply_to='+reply_to_id
              + '&content=' + encodeURIComponent(content)
              + '&send_new_feed=' + send_new_feed,
      success : function(res){
        var li_elm = jQuery(res);
        form_elm.find('ul.comments-list').prepend(li_elm);
        form_elm.find('textarea').val('');
        form_elm.find('.send-to').removeClass('checked');
      }
    });
  })

  jQuery('.feed-echo-form button.editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var cms_elm = elm.closest('.comments');
    cms_elm.remove();
  });
});

pie.load(function(){
  //传阅
  var ftelm = jQuery('<div class="feed-transmit-form popdiv">'+
    '<div class="ipt"><textarea class="transmit-inputer"></textarea></div>'+
    '<div class="btns">'+
      '<a class="button editable-submit" href="javascript:;">发送</button>'+
      '<a class="button editable-cancel" href="javascript:;">取消</button>'+
    '</div>'+
  '</div>');
  
  jQuery('.newsfeed .feed .ops .transmit').live('click',function(){
    var elm = jQuery(this);
    var o = elm.offset();
    var id = elm.closest('.f').attr('data-id');

    if(id == ftelm.attr('data-feed-id')){
      ftelm.remove();
      ftelm.attr('data-feed-id','');
      ftelm.find('textarea').val('');
    }else{
      ftelm.css('left',o.left + elm.outerWidth() - 400).css('top',o.top + elm.outerHeight());
      ftelm.attr('data-feed-id',id);

      jQuery('body').append(ftelm);
    }
  });

  jQuery('.feed-transmit-form a.button.editable-cancel').live('click',function(){
    ftelm.remove();
    ftelm.attr('data-feed-id','');
    ftelm.find('textarea').val('');
  });

  jQuery('.feed-transmit-form a.button.editable-submit').live('click',function(){
    var quote_of_id = ftelm.attr('data-feed-id');
    var content = ftelm.find('textarea').val();
    
    jQuery.ajax({
      url  : '/feeds/quote',
      type : 'POST',
      data : 'quote_of='+quote_of_id
              + '&content=' + encodeURIComponent(content),
      success : function(res){
        ftelm.remove();
        ftelm.attr('data-feed-id','');
        ftelm.find('textarea').val('');
        alert('发送成功！')
      }
    });
  });


  //删除事件
  jQuery('.mplist.feeds .ops .del').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.feed.mpli').children('.f');
    var id = f_elm.attr('data-id');

    var li_elm = f_elm.closest('li');

    if(confirm('确定要删除吗？')){
      li_elm.slideUp({
        complete : function(){
          li_elm.remove();
        }
      })

      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id),
        type :'delete',
        success : function(res){

        },
        error : function(data){
        }
      });
    }
  });
})

pie.load(function(){

  var ti_elm = jQuery('<div class="todo-items-config popdiv">'+
    '<div class="title">任务项</div>'+
    '<div class="items"></div>'+
    '<div class="form">'+
      '<textarea class="text item-content inline" value="" />'+
    '</div>'+
    '<div class="btns">'+
      '<a class="button editable-submit" href="javascript:;">发送</button>'+
      '<a class="button editable-cancel" href="javascript:;">取消</button>'+
    '</div>'+
  '</div>');

  jQuery('li.mpli.feed .feed-todo .add-items').live('click',function(){
    var elm = jQuery(this);
    var o = elm.offset();
    var todo_elm = jQuery(this).closest('.feed-todo');
    var todo_id = todo_elm.attr('data-id');

    var items_elm = ti_elm.find('.items');
    items_elm.html('');
    items_elm.addClass('aj-loading');

    if(todo_id == ti_elm.attr('data-todo-id')){
      ti_elm.remove();
      ti_elm.attr('data-todo-id','');
      ti_elm.find('.item-content').val('');
    }else{
      ti_elm.css('left',o.left + elm.outerWidth() + 4).css('top',o.top-2);
      ti_elm.attr('data-todo-id',todo_id);
      jQuery('body').append(ti_elm);
      jQuery.ajax({
        url : '/todos/'+todo_id+'/todo_items',
        type: 'get',
        success:function(res){
          var aj_elm = jQuery(res);
          items_elm.before(aj_elm);
          items_elm.remove();
        }
      })
    }
  });

  jQuery('.todo-items-config a.button.editable-cancel').live('click',function(){
    ti_elm.remove();
    ti_elm.attr('data-todo-id','');
    ti_elm.find('.item-content').val('');
  });

  jQuery('.todo-items-config a.button.editable-submit').live('click',function(){
    var elm = jQuery(this);
    var c_elm = elm.closest('.todo-items-config')
    var todo_id = c_elm.attr('data-todo-id');
    var content = c_elm.find('.item-content').val();

    var todo_elm = jQuery('li.mpli.feed .feed-todo[data-id='+todo_id+']');

    jQuery.ajax({
      url  : '/todos/'+todo_id+'/todo_items',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        todo_elm.before(jQuery(res));
        todo_elm.remove();
      },
      error : function(){
        todo_elm.removeClass('aj-loading');
        alert('任务项操作失败');
      }
    })
  })
})

pie.load(function(){
  jQuery('.index-todos .to .action .move-up').live('click',function(){
    var elm = jQuery(this);
    var to_elm = elm.closest('.to');
    var todo_id = to_elm.attr('data-id');

    var prev_to_elm = to_elm.prev('.to');
    if(prev_to_elm != []){
      prev_to_elm.before(to_elm);
      to_elm.hide().fadeIn();
      jQuery.ajax({
        url  : '/todos/'+todo_id+'/move_up',
        type : 'put',
        success : function(res){
          pie.log(res)
        }
      })
    }
  });

  jQuery('.index-todos .to .action .move-down').live('click',function(){
    var elm = jQuery(this);
    var to_elm = elm.closest('.to');
    var todo_id = to_elm.attr('data-id');

    var next_to_elm = to_elm.next('.to');
    if(next_to_elm != []){
      next_to_elm.after(to_elm);
      to_elm.hide().fadeIn();
      jQuery.ajax({
        url  : '/todos/'+todo_id+'/move_down',
        type : 'put',
        success : function(res){
          pie.log(res)
        }
      })
    }
  });

  //改变任务状态
  jQuery('.index-todos .to .status').live('click',function(){
    var elm = jQuery(this);
    var to_elm = elm.closest('.to');
    var todo_id = to_elm.attr('data-id');

    var changeto_status = 'ready'
    var changeto_status_name = '预备'

    if(elm.hasClass('ready')){
      changeto_status = 'doing'
      changeto_status_name = '执行'
    }
    if(elm.hasClass('doing')){
      changeto_status = 'done'
      changeto_status_name = '完成'
    }
    if(elm.hasClass('done')){
      changeto_status = 'drop'
      changeto_status_name = '放弃'
    }
    if(elm.hasClass('drop')){
      changeto_status = 'ready'
      changeto_status_name = '预备'
    }

    elm
      .removeClass('ready')
      .removeClass('doing')
      .removeClass('done')
      .removeClass('drop')
      .addClass(changeto_status)

    elm.find('.stext').html(changeto_status_name);

    jQuery.ajax({
      url  : '/todos/'+todo_id+'/change_status',
      data : 'status='+changeto_status,
      type : 'put',
      success : function(){
        //nothing
      }
    })
  })

  jQuery('.index-todos .to .memo-inputer a.memo-submit').live('click',function(){
    var elm = jQuery(this);
    var ipt_elm = elm.closest('.memo-inputer').find('textarea');
    var memo = ipt_elm.val();
    var todo_id = elm.closest('.to').attr('data-id');
    
    jQuery.ajax({
      url  : 'todos/'+todo_id+'/add_memo',
      type : 'put',
      data : 'memo='+encodeURIComponent(memo),
      success : function(res){
        var memo_elm = elm.closest('.memo');
        var new_memo_elm = jQuery(res).find('.memo');
        memo_elm.before(new_memo_elm);
        memo_elm.remove();
      }
    })
  })

  jQuery('.index-todos .to .memo a.edit-memo').live('click',function(){
    jQuery(this).closest('.memo').find('.memo-inputer').show();
  })
})