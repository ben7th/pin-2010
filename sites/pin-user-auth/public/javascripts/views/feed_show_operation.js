pie.load(function(){
  // 发表观点
  //jQuery('.page-show-add-viewpoint .add-viewpoint-inputer .inputer').qeditor();

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
        jQuery('.page-feed-viewpoints').append(vp_elm);
        vp_elm.hide().fadeIn('fast');
        jQuery('.page-show-add-viewpoint').addClass('vp-added');
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
          var comments_list_elm = jQuery('<div>'+res+'</div>');
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

    jQuery.ajax({
      url : '/viewpoints/'+viewpoint_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var li_elm = jQuery(res).find('li');
        var list_elm = comments_elm.find('.list');
        list_elm.prepend(li_elm);
        elm.closest('.comments').find('.ipt .inputer').val('');
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

      jQuery.ajax({
        url : '/viewpoint_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut(200);
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
    var vote_elm = vp_elm.find('.vote-ops');

    main_elm.hide();
    vote_elm.hide();
    main_elm.after(form_elm);
    form_elm.show();
  });

  //确定
  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var content = form_elm.find('.inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_vp_elm = jQuery(res);
        vp_elm.after(new_vp_elm);
        vp_elm.remove();
      }
    })
  });


  //取消
  jQuery('.page-feed-viewpoints .viewpoint .viewpoint-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var main_elm = vp_elm.find('.main');
    var vote_elm = vp_elm.find('.vote-ops');

    main_elm.show();
    vote_elm.show();
    form_elm.remove();
  });

});

pie.load(function(){
  //修改主题正文
  jQuery('.page-feed-show .detail-data .edit-detail .edit').live('click',function(){
    var form_elm = jQuery('.feed-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');

    form_elm.show();
    detail_elm.hide();
  });

  //确定
  jQuery('.page-feed-show .feed-detail-edit-form .editable-submit').live('click',function(){
    var form_elm = jQuery('.feed-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');
    var feed_id = feed_elm.attr('data-id');
    var content = form_elm.find('.detail-inputer').val();

    //  put /feeds/:id/update_detail params[:detail]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/update_detail',
      type : 'put',
      data : 'detail='+encodeURIComponent(content),
      success : function(res){
        var new_feed_elm = jQuery(res);
        feed_elm.after(new_feed_elm);
        feed_elm.remove();
        form_elm.hide();
      }
    })
  });


  //取消
  jQuery('.page-feed-show .feed-detail-edit-form .editable-cancel').live('click',function(){
    var form_elm = jQuery('.feed-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var detail_elm = feed_elm.find('.detail-data');
    detail_elm.show();
    form_elm.hide();
  });

});


pie.load(function(){
  //修改主题页的标题
  jQuery('.feed-show-page-head .ftitle .edit-feed-title .edit').live('click',function(){
    var form_elm = jQuery('.feed-title-edit-form')
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');
    var content_elm = head_elm.find('.ftitle .feed-title');

    form_elm.show();
    content_elm.hide();
  });

  //取消
  jQuery('.feed-show-page-head .ftitle .feed-title-edit-form .editable-cancel').live('click',function(){
    var form_elm = jQuery('.feed-title-edit-form')
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');
    var content_elm = head_elm.find('.ftitle .feed-title');

    form_elm.hide();
    content_elm.show();
  });

  //确定
  jQuery('.feed-show-page-head .ftitle .feed-title-edit-form .editable-submit').live('click',function(){
    var form_elm = jQuery('.feed-title-edit-form')
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var content = form_elm.find('.content-inputer').val();

    //  put /feeds/:id/update_content params[:detail]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/update_content',
      type : 'put',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_ftitle_elm = jQuery(res).find('.ftitle');
        var old_ftitle_elm = head_elm.find('.ftitle');
        old_ftitle_elm.after(new_ftitle_elm);
        old_ftitle_elm.remove();
      }
    })
  });
});

pie.load(function(){
  //修改主题页的tag
  jQuery('.feed-show-page-head .ftag .edit-tags .edit').live('click',function(){
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var form_elm = head_elm.find('.feed-tags-edit-form')
    var tags_elm = head_elm.find('.feed-tags');

    form_elm.show();
    tags_elm.hide();
  });

  //确定
  jQuery('.feed-show-page-head .ftag .feed-tags-edit-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var form_elm = head_elm.find('.feed-tags-edit-form')

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    var tag_names = form_elm.find('.tags-inputer').val();

    //  post /feeds/:id/add_tags        params[:tag_names]

    jQuery.ajax({
      url : '/feeds/'+feed_id+'/change_tags',
      type : 'put',
      data : 'tag_names='+encodeURIComponent(tag_names),
      success : function(res){
        var new_ftag_elm = jQuery(res).find('.ftag');
        var old_ftag_elm = head_elm.find('.ftag');
        old_ftag_elm.after(new_ftag_elm);
        old_ftag_elm.remove();
      }
    })
  });

  //取消
  jQuery('.feed-show-page-head .ftag .feed-tags-edit-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var head_elm = elm.closest('.feed-show-page-head');

    var form_elm = head_elm.find('.feed-tags-edit-form')
    var tags_elm = head_elm.find('.feed-tags');

    form_elm.hide();
    tags_elm.show();
  });
})


pie.load(function(){
  //show页面的关注

  jQuery('.show-page-ops .fav').live('click',function(){
    var fav_elm = jQuery('.show-page-ops .fav');
    var unfav_elm = jQuery('.show-page-ops .unfav');
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    jQuery.ajax({
      url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id+'/fav'),
      type :'post',
      success : function(res){
        fav_elm.hide();
        unfav_elm.show();
      }
    });
  });

  jQuery('.show-page-ops .unfav').live('click',function(){
    var fav_elm = jQuery('.show-page-ops .fav');
    var unfav_elm = jQuery('.show-page-ops .unfav');
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    jQuery.ajax({
      url  :pie.pin_url_for('pin-user-auth','/feeds/'+feed_id+'/unfav'),
      type :'delete',
      success : function(res){
        fav_elm.show();
        unfav_elm.hide();
      }
    });
  });
});


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

  jQuery('.page-feed-show .feed-echo-form .comments-list .delete').live('click',function(){
    var elm = jQuery(this);
    var comment_elm = elm.closest('.comment');
    var comment_id = comment_elm.attr('data-comment-id');

    elm.confirm_dialog('确定要删除这条评论吗',function(){
      jQuery.ajax({
        url : '/feed_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut();
        }
      })
    });
  })
});

pie.load(function(){
  // 不值得讨论
  jQuery('.page-feed-show .ops .spam').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.page-feed-show');
    var feed_id = feed_elm.attr('data-id');
    elm.confirm_dialog('如果很多人都这么觉得，主题将被隐藏。',function(){
      // post /feeds/id/add_spam_mark
      jQuery.ajax({
        url : '/feeds/'+feed_id+'/add_spam_mark',
        type : 'post',
        success : function(res){
          var new_feed_elm = jQuery(res);
          feed_elm.after(new_feed_elm);
          feed_elm.remove();
          jQuery('.tipsy').remove();
          //重新加载tipr 在有更好的方法之前 此处暂时先这样写，
          new_feed_elm.find('[tipr]').tipsy({html:true,gravity:'w',title:function(){
            var tip = this.getAttribute('tipr')
            var doms = jQuery(tip)
            if(doms.length == 0) return tip;
            return doms.html();
          }});
        }
      })
    })
  })
})

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
      success : function(res){
        resort_viewpoints(res,vp_id);
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
      success : function(res){
        resort_viewpoints(res,vp_id);
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
      success : function(res){
        resort_viewpoints(res,vp_id);
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

pie.load(function(){
  //删除被邀请者
  jQuery('.show-page-be-invited-users .user .delete').live('click',function(){
    var elm = jQuery(this);
    var user_elm = elm.closest('.user');
    var user_id = user_elm.attr('data-id');
    var feed_id = jQuery('.page-feed-show').attr('data-id');
    // delete /feeds/:id/cancel_invite params[:user_id]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/cancel_invite',
      type : 'delete',
      data : 'user_id='+user_id,
      success : function(){
        user_elm.fadeOut(200,function(){user_elm.remove()});
      }
    })
  })
})

//邮件邀请
pie.load(function(){
  jQuery('.show-page-invite-email .send-invite-email').live('click',function(){
    var form_elm = jQuery('.show-page-feed-share-form');

    jQuery.facebox(
      '<h3 class="f_box">发送主题讨论邀请邮件</h3>'+
      '<div class="show-page-feed-share-form">'+
        '<div class="flash-success" style="display:none;"><span>邮件发送完毕</span></div>'+
        form_elm.html()+
      '</div>'
    )
  })

  jQuery('.show-page-feed-share-form .editable-cancel').live('click',function(){
    jQuery.facebox.close();
  })

  //发送邮件
  jQuery('.show-page-feed-share-form .editable-submit').live('click',function(){
//    post /feeds/id/send_invite_email
//      params[:email]
//      params[:title]
//      params[:postscript]
    var elm = jQuery(this);
    var form_elm = elm.closest('.show-page-feed-share-form');
    var email = form_elm.find('input.email').val();
    var title = form_elm.find('input.title').val();
    var postscript = form_elm.find('textarea.postscript').val();

    if(jQuery.string(email).blank()){
      pie.inputflash(form_elm.find('input.email'));
      return;
    }

    if(jQuery.string(title).blank()){
      pie.inputflash(form_elm.find('input.title'));
      return;
    }

    var feed_id = jQuery('.page-feed-show').attr('data-id');
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/send_invite_email',
      type : 'post',
      data : 'email='+encodeURIComponent(email)+
        '&title='+encodeURIComponent(title)+
        '&postscript='+encodeURIComponent(postscript),
      success : function(){
        form_elm.find('.flash-success').fadeIn(100);
        setTimeout(function(){jQuery.facebox.close();},500);
      }
    })

  })
})

//转发链接
pie.load(function(){
  jQuery('.show-page-invite-link-share .send-invite-link-share').live('click',function(){
    var form_elm = jQuery('.show-page-feed-link-share-form');

    jQuery.facebox(
      '<h3 class="f_box">转发主题链接地址</h3>'+
      '<div class="show-page-feed-link-share-form">'+
        form_elm.html()+
      '</div>'
    )

    var cnt_elm = jQuery('#facebox textarea');
    var start = 0;
    var end = cnt_elm.val().length;
    cnt_elm[0].setSelectionRange(start,end);
  })

  jQuery('.show-page-feed-link-share-form .editable-cancel').live('click',function(){
    jQuery.facebox.close();
  })
});

pie.feed_image_resize = function(elm){
  var width = elm.width();
  var height = elm.height();

  if(width<=600) return;

  // w/600 = h/x
  // x = 600h/w

  var new_height = 600 * height / width;
  elm.attr('width',600).attr('height',new_height)
}