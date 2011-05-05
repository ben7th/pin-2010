pie.load(function(){
  // 发表观点
  //jQuery('.page-show-add-viewpoint .add-viewpoint-inputer .inputer').qeditor();

  jQuery('.page-show-add-viewpoint .subm .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var psav_elm = elm.closest('.page-show-add-viewpoint');
    var feed_id = psav_elm.attr('data-feed-id');
    var content = psav_elm.find('.add-viewpoint-inputer .inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    pie.show_loading_bar();
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var vp_elm = jQuery(res);
        jQuery('.page-feed-viewpoints').append(vp_elm);
        vp_elm.hide().fadeIn('fast');
        jQuery('.page-show-add-viewpoint').addClass('vp-added');
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });
});

pie.load(function(){
  var comments_elm = jQuery(
    '<div class="comments darkbg">'+
      '<div class="comment-form">'+
        '<div class="ipt"><textarea class="inputer"/></div>'+
        '<div class="btns">'+
          '<a class="button editable-submit" href="javascript:;">发送</a>'+
          '<a class="button editable-cancel" href="javascript:;">取消</a>'+
        '</div>'+
      '</div>'+
      '<div class="list"></div>'+
    '</div>'
  )

  // 针对观点的评论
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

  // 确定
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

  //取消
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
  var form_elm = jQuery(
    '<div class="viewpoint-edit-form">'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</a>'+
        '<a class="button editable-cancel" href="javascript:;">取消</a>'+
      '</div>'+
    '</div>'
  )

  //修改观点
  jQuery('.page-feed-viewpoints .viewpoint .edit-vp .edit').live('click',function(){
    var ori_form_elm = jQuery('.page-show-add-viewpoint .point-form .add-viewpoint-inputer');
    form_elm.find('.btns').before(ori_form_elm);

    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');

    main_elm.hide();
    main_elm.after(form_elm);
    form_elm.show();
  });

  //确定
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


  //取消
  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');
    main_elm.show();
    form_elm.remove();
  });

});

pie.load(function(){
  var form_elm = jQuery('.feed-detail-edit-form')

  //修改话题正文
  jQuery('.page-feed-show .detail-data .edit-detail .edit').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');

    form_elm.show();
    detail_elm.hide();
  });

  //确定
  jQuery('.page-feed-show .feed-detail-edit-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');
    var feed_id = feed_elm.attr('data-id');
    var content = form_elm.find('.detail-inputer').val();

    //  put /feeds/:id/update_detail params[:detail]
    pie.show_loading_bar();
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/update_detail',
      type : 'put',
      data : 'detail='+encodeURIComponent(content),
      success : function(res){
        var new_detail_elm = jQuery(res);
        detail_elm.after(new_detail_elm);
        detail_elm.remove();
        form_elm.hide();
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });


  //取消
  jQuery('.page-feed-show .feed-detail-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');
    detail_elm.show();
    form_elm.hide();
  });

});


pie.load(function(){
  //show页面的关注
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

pie.load(function(){
  //show页面的删除
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


pie.load(function(){
  //show页面的传播
  var ftelm = jQuery('<div class="feed-transmit-form-show popdiv">'+
    '<div class="title">传播一个话题</div>'+
    '<div class="flash-success"><span>发送成功</span></div>'+
    '<div class="ori-feed"></div>'+
    '<div class="ipt"><textarea class="transmit-inputer"></textarea></div>'+
    '<div class="btns">'+
      '<a class="button editable-submit" href="javascript:;">发送</a>'+
      '<a class="button editable-cancel" href="javascript:;">取消</a>'+
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

  //确定按钮
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

pie.load(function(){
  //show页面的评论
  jQuery('.page-feed-show .ops .echo').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var feed_id = feed_elm.attr('data-id');
    var footmisc_elm = feed_elm.find('.footmisc')

    if(footmisc_elm.next('.comments').length > 0){
      feed_elm.find('.comments').remove();
      return;
    }

    var cms_elm = jQuery('<div class="comments darkbg loading"></div>')
    feed_elm.append(cms_elm);

    jQuery.ajax({
      url  : "/feeds/" + feed_id + "/aj_comments",
      type : 'GET',
      success : function(res){
        var res_elm = jQuery(res);
        cms_elm.append(res_elm).removeClass('loading');
      }
    })
    
  })

  jQuery('.page-feed-show .feed-echo-form .send-to').live('click',function(){
    jQuery(this).toggleClass('checked');
  })

  jQuery('.page-feed-show .feed-echo-form button.editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var cms_elm = elm.closest('.comments');
    cms_elm.remove();
  });

  jQuery('.page-feed-show .feed-echo-form button.editable-submit').live('click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('.feed-echo-form');
    var reply_to_id = form_elm.attr('data-feed-id');

    var content = form_elm.find('textarea').val();
    var send_new_feed = form_elm.find('.send-to').hasClass('checked');

    pie.show_loading_bar();
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
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    });
  })

  jQuery('.page-feed-show .feed-echo-form .comments-list .delete').live('click',function(){
    var elm = jQuery(this);
    var comment_elm = elm.closest('.comment');
    var comment_id = comment_elm.attr('data-comment-id');

    elm.confirm_dialog('确定要删除这条评论吗',function(){
      pie.show_loading_bar();
      jQuery.ajax({
        url : '/feed_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut();
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      })
    });
  })
});

pie.load(function(){
  // 投赞成
  jQuery('.page-feed-viewpoints .viewpoint .vote-up').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var vp_id = vp_elm.attr('data-id');

    // POST /viewpoints/:id/vote_up
    jQuery.ajax({
      url : '/viewpoints/'+vp_id+'/vote_up',
      type : 'post',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        resort_viewpoints(res,vp_id);
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });

  // 投反对
  jQuery('.page-feed-viewpoints .viewpoint .vote-down').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var vp_id = vp_elm.attr('data-id');

    // POST /viewpoints/:id/vote_up
    jQuery.ajax({
      url : '/viewpoints/'+vp_id+'/vote_down',
      type : 'post',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        resort_viewpoints(res,vp_id);
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });

  //取消投票
  jQuery('.page-feed-viewpoints .viewpoint .voted-up, .page-feed-viewpoints .viewpoint .voted-down')
  .live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var vp_id = vp_elm.attr('data-id');
    //delete /viewpints/:id/cancel_vote
    jQuery.ajax({
      url : '/viewpoints/'+vp_id+'/cancel_vote',
      type : 'delete',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        resort_viewpoints(res,vp_id);
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })

  //重新加载观点dom
  function resort_viewpoints(res,vp_id){
    var new_elm = jQuery('<div>'+res+'</div>');
    var new_vps_elm = new_elm.find('.page-feed-viewpoints');
    var old_vps_elm = jQuery('.page-feed-viewpoints');
    old_vps_elm.before(new_vps_elm).remove();
    jQuery('.page-feed-viewpoints .viewpoint[data-id='+vp_id+']').hide().fadeIn();
    jQuery('.tipsy').remove();

    //重新加载tipr 在有更好的方法之前 此处暂时先这样写，
    jQuery('.page-feed-viewpoints [tipr]').tipsy({html:true,gravity:'w',title:function(){
      var tip = this.getAttribute('tipr')
      var doms = jQuery(tip)
      if(doms.length == 0) return tip;
      return doms.html();
    }});
  }
});