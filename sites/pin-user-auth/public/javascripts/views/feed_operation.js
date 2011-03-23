(function(){

  //回应
  jQuery('.feed-echo-form .send-to').live('click',function(){
    jQuery(this).toggleClass('checked');
  })

  jQuery('.mplist.feeds .ops .echo').live('click',function(){
    var elm = jQuery(this);
    var id = elm.closest('.mpli').find('.f').attr('data-id');
    var feed_elm = elm.closest('.feed.mpli');
    
    if(feed_elm.find('.comments').length > 0){
      feed_elm.find('.comments').remove();
      return;
    }

    var cms_elm = jQuery('<div class="comments darkbg loading"></div>')
    feed_elm.append(cms_elm);

    jQuery.ajax({
      url  : "/feeds/"+id+"/aj_comments",
      type : 'GET',
      success : function(res){
        var res_elm = jQuery(res);
        cms_elm.append(res_elm).removeClass('loading');
      }
    })

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

  //传阅
  var ftelm = jQuery('<div class="feed-transmit-form darkbg1">'+
    '<div class="ipt"><textarea class="transmit-inputer"></textarea></div>'+
    '<div class="btns">'+
      '<button class="editable-submit">发送</button>'+
      '<button class="editable-cancel">取消</button>'+
    '</div>'+
  '</div>');
  
  jQuery('.mplist.feeds .ops .transmit').live('click',function(){
    var elm = jQuery(this);
    var o = elm.offset();
    var id = elm.closest('.mpli').find('.f').attr('data-id');
    var feed_elm = elm.closest('.feed.mpli');

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

  jQuery('.feed-transmit-form button.editable-cancel').live('click',function(){
    ftelm.remove();
    ftelm.attr('data-feed-id','');
    ftelm.find('textarea').val('');
  });

  jQuery('.feed-transmit-form button.editable-submit').live('click',function(){
    var quote_of_id = ftelm.attr('data-feed-id');
    var content = ftelm.find('textarea').val();
    
    jQuery.ajax({
      url  : '/feeds/quote',
      type : 'POST',
      data : 'quote_of='+quote_of_id
              + '&content=' + encodeURIComponent(content),
      success : function(res){
//        var li_elm = jQuery(res);
//        form_elm.find('ul.comments-list').prepend(li_elm);
//        form_elm.find('textarea').val('');
//        form_elm.find('.send-to').removeClass('checked');
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

})();