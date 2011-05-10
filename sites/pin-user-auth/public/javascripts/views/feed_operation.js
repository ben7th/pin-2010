//发送feed
pie.load(function(){
  jQuery('.feed-form .ipter .feed-content').val('');
  jQuery('.feed-form .feed-detail').val('');

  jQuery('.feed-form .subm .subbtn').live('click',function(){
    var inputer_elm = jQuery('.feed-form .ipter .feed-content');
    var content = inputer_elm.val();

    var detail_inputer_elm = jQuery('.feed-form .feed-detail');
    var detail = detail_inputer_elm.val();

    var channel_id = jQuery('.feed-form .ipter .channel-id').val();

    var data;
    if(channel_id){
      data = 'content='+encodeURIComponent(content)+'&channel_id='+channel_id;
    }else{
      data = 'content='+encodeURIComponent(content)+'&detail='+encodeURIComponent(detail);
    }

    if(jQuery.string(content).blank()){
      pie.inputflash(inputer_elm);
      return;
    }

    jQuery.ajax({
      url  : pie.pin_url_for('pin-user-auth','/newsfeed/do_say'),
      type : 'post',
      data : data,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        //创建成功
        inputer_elm.val('');
        detail_inputer_elm.val('');
        var dom_elm = jQuery(res);
        var lis = dom_elm.find('li');
        jQuery('#mplist_feeds').prepend(lis);
        lis.hide().slideDown(400);
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    });
  });
})

//表单形态切换
pie.load(function(){
  jQuery('.feed-form .show-detail-ipt').live('click',function(){
    jQuery('.feed-form .detail-ipter').slideDown(200);
    jQuery(this).hide();
    jQuery('.feed-form .hide-detail-ipt').show();
    //put /account/feed_form_show_detail_cookie params[:value]
    jQuery.ajax({
      url : '/account/feed_form_show_detail_cookie',
      type : 'put',
      data : 'value=true'
    })
  })

  jQuery('.feed-form .hide-detail-ipt').live('click',function(){
    jQuery('.feed-form .detail-ipter').slideUp(200);
    jQuery(this).hide();
    jQuery('.feed-form .show-detail-ipt').show();
    //put /account/feed_form_show_detail_cookie params[:value]
    jQuery.ajax({
      url : '/account/feed_form_show_detail_cookie',
      type : 'put',
      data : 'value=false'
    })
  })
})


pie.load(function(){
  //标记
  jQuery('.newsfeed .feed .ops .fav').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.f');
    var id = f_elm.attr('data-id');

    var is_on = elm.hasClass('on');

    if(is_on){
      pie.show_loading_bar();
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/unfav'),
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
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/fav'),
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
  //传播
  var ftelm = jQuery('<div class="feed-transmit-form popdiv">'+
    '<div class="title">传播一个话题</div>'+
    '<div class="flash-success"><span>发送成功</span></div>'+
    '<div class="ori-feed"></div>'+
    '<div class="ipt"><textarea class="transmit-inputer"></textarea></div>'+
    '<div class="btns">'+
      '<a class="button editable-submit" href="javascript:;">发送</a>'+
      '<a class="button editable-cancel" href="javascript:;">取消</a>'+
    '</div>'+
  '</div>');
  
  jQuery('.newsfeed .feed .ops .transmit').live('click',function(){
    var elm = jQuery(this);
    var off = elm.offset();
    var fct = elm.closest('.feed').find('.ct').html();
    var feed_id = elm.closest('.f').attr('data-id');

    if(feed_id == ftelm.attr('data-feed-id')){
      ftelm.remove();
      ftelm.attr('data-feed-id','');
      ftelm.find('textarea').val('');
      ftelm.find('.ori-feed').html('');
    }else{
      ftelm.css('left',off.left - 200).css('top',off.top + elm.outerHeight() + 2);
      ftelm.attr('data-feed-id',feed_id);
      ftelm.find('.ori-feed').html(fct);
      ftelm.find('.flash-success').hide();
      jQuery('body').append(ftelm);
    }
  });

  //取消按钮
  jQuery('.feed-transmit-form .editable-cancel').live('click',function(){
    ftelm.remove();
    ftelm.attr('data-feed-id','');
    ftelm.find('textarea').val('');
  });

  //确定按钮
  jQuery('.feed-transmit-form a.button.editable-submit').live('click',function(){
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


  //隐藏feed
  jQuery('.newsfeed .feed .ops .del').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.feed.mpli').find('.f');
    var id = f_elm.attr('data-id');
    

    var li_elm = f_elm.closest('li');

    elm.confirm_dialog('确定要隐藏这个话题吗',function(){
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
    })
  });

  //恢复feed
  jQuery('.newsfeed .feed .ops .recover').live('click',function(){
    var elm = jQuery(this);
    var f_elm = elm.closest('.feed.mpli').find('.f');
    var id = f_elm.attr('data-id');


    var li_elm = f_elm.closest('li');

    elm.confirm_dialog('确定要恢复这个话题吗',function(){
      // put /feeds/id/recover
      li_elm.slideUp({
        complete : function(){
          li_elm.remove();
        }
      })
      
      jQuery.ajax({
        url  :pie.pin_url_for('pin-user-auth','/feeds/'+id+'/recover'),
        type :'put',
        beforeSend : function(){
          pie.show_loading_bar();
        },
        success : function(res){

        },
        complete : function(){
          pie.hide_loading_bar();
        }
      });
    })
  });

})

pie.load(function(){
  //发表观点
  jQuery('.newsfeed .feed .ops .add-viewpoint').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.f');
    var feed_id = feed_elm.attr('data-id');

    if(feed_elm.find('.add-viewpoint-form').length > 0){
      feed_elm.find('.add-viewpoint-form').remove();
      return;
    }

    var form_elm = jQuery(
      '<div class="add-viewpoint-form darkbg">'+
        '<div class="title">输入你的观点：</div>'+
        '<div class="ipt"><textarea class="inputer"/></div>'+
        '<div class="btns">'+
          '<a class="button editable-submit" href="javascript:;">发送</a>'+
          '<a class="button editable-cancel" href="javascript:;">取消</a>'+
        '</div>'+
      '</div>'
    )
    feed_elm.append(form_elm);
  })

  jQuery('.newsfeed .feed .add-viewpoint-form .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('.add-viewpoint-form');
    form_elm.remove();
  });

  jQuery('.newsfeed .feed .add-viewpoint-form .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('.add-viewpoint-form');
    var feed_elm = elm.closest('.f');
    var feed_id = feed_elm.attr('data-id');

    var content = form_elm.find('.inputer').val();
    
    jQuery.ajax({
      url  : '/feeds/'+feed_id+'/aj_viewpoint_in_list',
      type : 'POST',
      data : 'content=' + encodeURIComponent(content),

      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        var vp_elm = jQuery(res);
        feed_elm.find('.footmisc').next('.viewpoint').remove();
        feed_elm.find('.footmisc').after(vp_elm);
        form_elm.remove();
        feed_elm.find('.ops .add-viewpoint').after('<span class="quiet">已发表过观点</span>')
        feed_elm.find('.ops .add-viewpoint').remove();
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    });
  })
});


pie.load(function(){
  //显示较长观点的全文
  jQuery('.short-content a.show-detail').live('click',function(){
    var elm = jQuery(this);
    var short_elm = elm.closest('.short-content');
    var detail_elm = short_elm.next('.detail-content');
    short_elm.hide();
    detail_elm.fadeIn('fast');
  })
})

pie.load(function(){
  //confirm对话框，取代系统默认
  jQuery.fn.confirm_dialog = function(str,func){
    var elm = jQuery(this);
    var off = elm.offset();

    func == func || function(){};

    var dialog_elm = jQuery(
      '<div class="jq-confirm-dialog popdiv">'+
        '<div class="d">'+
          '<div class="data"><div class="icon">?</div>'+str+'</div>'+
          '<div class="btns">'+
            '<a class="button editable-submit" href="javascript:;">确定</a>'+
            '<a class="button editable-cancel" href="javascript:;">取消</a>'+
          '</div>'+
        '</div>'+
      '</div>'
    );

    jQuery('.jq-confirm-dialog').remove();
    dialog_elm.css('left',off.left - 100 + elm.outerWidth()/2).css('top',off.top - 83);
    jQuery('body').append(dialog_elm);

    //IE下面这样写有问题，估计是append之后不能立即fadeIn
    dialog_elm.hide().fadeIn();
    
    jQuery('.jq-confirm-dialog .editable-submit').unbind();
    jQuery('.jq-confirm-dialog .editable-submit').bind('click',function(){
      jQuery('.jq-confirm-dialog').remove();
      func();
    });
  }
  
  jQuery('.jq-confirm-dialog .editable-cancel').live('click',function(){
    jQuery('.jq-confirm-dialog').remove();
  })
});

//关于投票的通知
pie.load(function(){
  //清除所有通知
  jQuery('.homepage-new-voteup-tip .btns .clear-all').live('click',function(){
    //delete /tips/remove_all_viewpoint_vote_up_tips
    jQuery.ajax({
      url : '/tips/remove_all_viewpoint_vote_up_tips',
      type : 'delete',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        var hnvt_elm = jQuery('.homepage-new-voteup-tip');
        hnvt_elm.fadeOut(function(){
          hnvt_elm.remove();
        });
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });

  //清除单条通知
  jQuery('.homepage-new-voteup-tip .tip .delete').live('click',function(){
    var tip_elm = jQuery(this).closest('.tip')
    var tip_id = tip_elm.attr('data-id');

    //delete /tips/remove_viewpoint_vote_up_tip?tip_id
    jQuery.ajax({
      url : '/tips/remove_viewpoint_vote_up_tip',
      type : 'delete',
      data : 'tip_id='+tip_id,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        if(jQuery('.homepage-new-voteup-tip .tip').length == 1){
          var hnvt_elm = jQuery('.homepage-new-voteup-tip');
          hnvt_elm.fadeOut(function(){
            hnvt_elm.remove();
          });
        }else{
          tip_elm.fadeOut(function(){
            tip_elm.remove();
          });
        }
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })
})

//关于观点的通知
pie.load(function(){
  //清除所有通知
  jQuery('.homepage-new-viewpoint-tip .btns .clear-all').live('click',function(){
    //delete /tips/remove_all_viewpoint_vote_up_tips
    jQuery.ajax({
      url : '/tips/remove_all_viewpoint_tips',
      type : 'delete',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        var hnvt_elm = jQuery('.homepage-new-viewpoint-tip');
        hnvt_elm.fadeOut(function(){
          hnvt_elm.remove();
        });
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });

  //清除单条通知
  jQuery('.homepage-new-viewpoint-tip .tip .delete').live('click',function(){
    var tip_elm = jQuery(this).closest('.tip')
    var tip_id = tip_elm.attr('data-id');

    //delete /tips/remove_viewpoint_vote_up_tip?tip_id
    jQuery.ajax({
      url : '/tips/remove_viewpoint_tip',
      type : 'delete',
      data : 'tip_id='+tip_id,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        if(jQuery('.homepage-new-viewpoint-tip .tip').length == 1){
          var hnvt_elm = jQuery('.homepage-new-viewpoint-tip');
          hnvt_elm.fadeOut(function(){
            hnvt_elm.remove();
          });
        }else{
          tip_elm.fadeOut(function(){
            tip_elm.remove();
          });
        }
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })
})

//关于邀请的通知
pie.load(function(){
  //清除所有通知
  jQuery('.homepage-be-invited-tip .btns .clear-all').live('click',function(){
    //delete /tips/remove_all_viewpoint_vote_up_tips
    jQuery.ajax({
      url : '/tips/remove_all_feed_invite_tips',
      type : 'delete',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        var hnvt_elm = jQuery('.homepage-be-invited-tip');
        hnvt_elm.fadeOut(function(){
          hnvt_elm.remove();
        });
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });

  //清除单条通知
  jQuery('.homepage-be-invited-tip .tip .delete').live('click',function(){
    var tip_elm = jQuery(this).closest('.tip')
    var tip_id = tip_elm.attr('data-id');

    //delete /tips/remove_viewpoint_vote_up_tip?tip_id
    jQuery.ajax({
      url : '/tips/remove_feed_invite_tip',
      type : 'delete',
      data : 'tip_id='+tip_id,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        if(jQuery('.homepage-be-invited-tip .tip').length == 1){
          var hnvt_elm = jQuery('.homepage-be-invited-tip');
          hnvt_elm.fadeOut(function(){
            hnvt_elm.remove();
          });
        }else{
          tip_elm.fadeOut(function(){
            tip_elm.remove();
          });
        }
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })
})

//关于关注话题的通知
pie.load(function(){
  //清除所有通知
  jQuery('.homepage-fav-change-tip .btns .clear-all').live('click',function(){
	//delete /tips/remove_all_fav_feed_change_tips
    jQuery.ajax({
      url : '/tips/remove_all_fav_feed_change_tips',
      type : 'delete',
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        var hnvt_elm = jQuery('.homepage-fav-change-tip');
        hnvt_elm.fadeOut(function(){
          hnvt_elm.remove();
        });
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  });

  //清除单条通知
  jQuery('.homepage-fav-change-tip .tip .delete').live('click',function(){
    var tip_elm = jQuery(this).closest('.tip')
    var tip_id = tip_elm.attr('data-id');

    //delete /tips/remove_fav_feed_change_tip?tip_id
    jQuery.ajax({
      url : '/tips/remove_fav_feed_change_tip',
      type : 'delete',
      data : 'tip_id='+tip_id,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        if(jQuery('.homepage-fav-change-tip .tip').length == 1){
          var hnvt_elm = jQuery('.homepage-fav-change-tip');
          hnvt_elm.fadeOut(function(){
            hnvt_elm.remove();
          });
        }else{
          tip_elm.fadeOut(function(){
            tip_elm.remove();
          });
        }
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })
})