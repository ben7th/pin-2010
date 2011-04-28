pie.load(function(){
  jQuery('.page-show-add-viewpoint .subm .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var psav_elm = elm.closest('.page-show-add-viewpoint');
    var feed_id = psav_elm.attr('data-feed-id');
    var content = psav_elm.find('.add-viewpoint-inputer .inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var vp_elm = jQuery(res);
        jQuery('.feed-viewpoints').append(vp_elm);
        vp_elm.hide().fadeIn('fast');
        jQuery('.page-show-add-viewpoint').addClass('vp-added');
      }
    })
  });


  var comments_elm = jQuery(
    '<div class="comments darkbg">'+
      '<div class="comment-form">'+
        '<div class="ipt"><textarea class="inputer"/></div>'+
        '<div class="btns">'+
          '<a class="button editable-submit" href="javascript:;">发送</button>'+
          '<a class="button editable-cancel" href="javascript:;">取消</button>'+
        '</div>'+
      '</div>'+
      '<div class="list"></div>'+
    '</div>'
  )

  //观点的评论
  jQuery('.page-feed-viewpoints .viewpoint .ops .echo').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var viewpoint_id = vp_elm.attr('data-id');
    var foot_elm = vp_elm.find('.footmisc');

    if(foot_elm.next('.comments').length == 0){
      foot_elm.after(comments_elm);
      
      // get /viewpoints/:id/aj-comments
      var list_elm = comments_elm.find('.list');
      list_elm.html('').addClass('aj-loading');
      jQuery.ajax({
        url : '/viewpoints/'+viewpoint_id+'/aj_comments',
        type : 'get',
        success : function(res){
          var comments_list_elm = jQuery(res);
          list_elm.html(comments_list_elm.html()).removeClass('aj-loading');;
        }
      })
    }else{
      comments_elm.remove();
    }
  })

  jQuery('.page-feed-viewpoints .viewpoint .comments .btns .editable-submit').live('click',function(){
    //post /viewpoints/:id/comments params[:content]
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var viewpoint_id = vp_elm.attr('data-id');
    var content = elm.closest('.comments').find('.ipt .inputer').val();

    pie.show_loading_bar();
    jQuery.ajax({
      url : '/viewpoints/'+viewpoint_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var li_elm = jQuery(res).find('li');
        var list_elm = comments_elm.find('.list');
        list_elm.prepend(li_elm);
        elm.closest('.comments').find('.ipt .inputer').val('');
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })

  jQuery('.page-feed-viewpoints .viewpoint .comments .btns .editable-cancel').live('click',function(){
    comments_elm.remove();
  })

  //删除观点的评论
  jQuery('.page-feed-viewpoints .viewpoint .comments .comment .delete').live('click',function(){
    var elm = jQuery(this);
    var comment_elm = elm.closest('.comment')
    var comment_id = comment_elm.attr('data-id');
    elm.confirm_dialog('确定要删除这条评论吗',function(){
      // delete /viewpoint_comments/:id

      pie.show_loading_bar();
      jQuery.ajax({
        url : '/viewpoint_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut(200);
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      })
    });
  })
});

pie.load(function(){
  //修改观点
  var ori_form_elm = jQuery('.page-show-add-viewpoint .point-form .add-viewpoint-inputer');
  var form_elm = jQuery(
    '<div class="viewpoint-edit-form">'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</button>'+
        '<a class="button editable-cancel" href="javascript:;">取消</button>'+
      '</div>'+
    '</div>'
  )
  form_elm.find('.btns').before(ori_form_elm);

  jQuery('.page-feed-viewpoints .viewpoint .ops .edit').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');

    main_elm.hide();
    main_elm.after(form_elm);
    form_elm.show();
  });

  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var content = form_elm.find('.inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    pie.show_loading_bar();
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_vp_elm = jQuery(res);
        vp_elm.after(new_vp_elm);
        vp_elm.remove();
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })

  });


  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');
    main_elm.show();
    form_elm.remove();
  });

});

//show页面的关注
pie.load(function(){
  jQuery('.page-feed-show .ops .fav').live('click',function(){
    var elm = jQuery(this);
    var feed_id = elm.closest('.page-feed-show').attr('data-id');
    
    var is_on = elm.hasClass('on');

    if(is_on){
      pie.show_loading_bar();
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id+'/unfav'),
        type :'delete',
        success : function(res){
          elm.removeClass('on').addClass('off');
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      });
    }else{
      pie.show_loading_bar();
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id+'/fav'),
        type :'post',
        success : function(res){
          elm.removeClass('off').addClass('on');
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      });
    }
  });
});

//show页面的删除
pie.load(function(){
  jQuery('.page-feed-show .ops .del').live('click',function(){
    var elm = jQuery(this);
    var feed_id = elm.closest('.page-feed-show').attr('data-id');

    elm.confirm_dialog('确定要删除这个话题吗',function(){
      pie.show_loading_bar();
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id),
        type :'delete',
        success : function(res){
          window.location.href = pie.pin_url_for('pin-user-auth','/');
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      });
    });
  });
});

//show页面的传播
pie.load(function(){
  var ftelm = jQuery('<div class="feed-transmit-form-show popdiv">'+
    '<div class="title">传播一个话题</div>'+
    '<div class="flash-success"><span>发送成功</span></div>'+
    '<div class="ori-feed"></div>'+
    '<div class="ipt"><textarea class="transmit-inputer"></textarea></div>'+
    '<div class="btns">'+
      '<a class="button editable-submit" href="javascript:;">发送</button>'+
      '<a class="button editable-cancel" href="javascript:;">取消</button>'+
    '</div>'+
  '</div>');

  jQuery('.page-feed-show .ops .transmit').live('click',function(){
    var elm = jQuery(this);
    var feed_id = elm.closest('.page-feed-show').attr('data-id');
    var fct = elm.closest('.page-feed-show').find('.ct').html();
    var off = elm.offset();

    if(feed_id == ftelm.attr('data-feed-id')){
      ftelm.remove();
      ftelm.attr('data-feed-id','');
      ftelm.find('textarea').val('');
      ftelm.find('.ori-feed').html('');
    }else{
      ftelm.css('left',off.left - 5).css('top',off.top + elm.outerHeight() + 2);
      ftelm.attr('data-feed-id',feed_id);
      ftelm.find('.ori-feed').html(fct);
      ftelm.find('.flash-success').hide();
      jQuery('body').append(ftelm);
    }
  });

  //取消按钮
  jQuery('.feed-transmit-form-show .editable-cancel').live('click',function(){
    ftelm.remove();
    ftelm.attr('data-feed-id','');
    ftelm.find('textarea').val('');
  });

  jQuery('.feed-transmit-form-show .editable-submit').live('click',function(){
    var quote_of_id = ftelm.attr('data-feed-id');
    var content = ftelm.find('textarea').val();

    pie.show_loading_bar();
    jQuery.ajax({
      url  : '/feeds/quote',
      type : 'POST',
      data : 'quote_of='+quote_of_id+
             '&content=' + encodeURIComponent(content),
      success : function(res){
        ftelm.find('.flash-success').fadeIn(200);
        setTimeout(function(){
          ftelm.remove();
          ftelm.attr('data-feed-id','');
          ftelm.find('textarea').val('');
        },400)
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    });
  });
})
