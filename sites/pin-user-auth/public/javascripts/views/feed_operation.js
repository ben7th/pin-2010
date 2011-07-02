//发送feed
pie.load(function(){
  jQuery('.page-new-feed-form .content-ipter').live('focus',function(){
    var t_elm = jQuery('.page-new-feed-tips .tip.what-is-it');
    if(t_elm.css('display')!='none') return;
    jQuery('.page-new-feed-tips .tip').hide();
    t_elm.fadeIn();
  })

  jQuery('.page-new-feed-form .detail-ipter').live('focus',function(){
    var t_elm = jQuery('.page-new-feed-tips .tip.format-help');
    if(t_elm.css('display')!='none') return;
    jQuery('.page-new-feed-tips .tip').hide();
    t_elm.fadeIn();
  })

  jQuery('.page-new-feed-form .tags-ipter').live('focus',function(){
    var t_elm = jQuery('.page-new-feed-tips .tip.tag-help');
    if(t_elm.css('display')!='none') return;
    jQuery('.page-new-feed-tips .tip').hide();
    t_elm.fadeIn();
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
    '<div class="title">传播一个主题</div>'+
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

    elm.confirm_dialog('确定要隐藏这个主题吗',function(){
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

    elm.confirm_dialog('确定要恢复这个主题吗',function(){
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

//通知相关
//用户通知的清除方法
pie.load(function(){
  //清除所有通知
  jQuery('.homepage-user-notices .btns .clear-all').live('click',function(){
    // delete /tips/remove_all_user_tips

    var elm = jQuery(this);

    elm.confirm_dialog('确定这样做吗',function(){

      jQuery.ajax({
        url : '/tips/remove_all_user_tips',
        type : 'delete',
        success : function(res){
          var hnvt_elm = jQuery('.homepage-user-notices');
          hnvt_elm.fadeOut(function(){
            hnvt_elm.remove();
            pie.recount_feed_notice();
          });
        }
      })
    });

  });

  //清除单条通知
  jQuery('.homepage-user-notices .tip .delete').live('click',function(){
    var tip_elm = jQuery(this).closest('.tip')
    var tip_id = tip_elm.attr('data-id');

    // delete /tips/remove_user_tip params[:tip_id]

    jQuery.ajax({
      url : '/tips/remove_user_tip',
      type : 'delete',
      data : 'tip_id='+tip_id,
      success : function(res){
        if(jQuery('.homepage-user-notices .tip').length == 1){
          var hnvt_elm = jQuery('.homepage-user-notices');
          hnvt_elm.fadeOut(function(){
            hnvt_elm.remove();
            pie.recount_feed_notice();
          });
        }else{
          tip_elm.fadeOut(function(){
            tip_elm.remove();
            pie.recount_feed_notice();
          });
        }
      }
    })
  })
})

//首页tab切换
//TODO 先注掉，稍后换成github那种效果
//pie.load(function(){
//  jQuery('.index-page-tabs .tab.feeds').live('click',function(){
//    var elm = jQuery(this);
//    if(elm.hasClass('selected')){
//      return;
//    }
//
//    jQuery('.index-page-tabs .tab').removeClass('selected');
//    elm.addClass('selected');
//
//    jQuery('.index-tab-ct').hide();
//    jQuery('.index-tab-ct.feeds').fadeIn(200);
//  })
//
//  jQuery('.index-page-tabs .tab.logs').live('click',function(){
//    var elm = jQuery(this);
//    if(elm.hasClass('selected')){
//      return;
//    }
//
//    jQuery('.index-page-tabs .tab').removeClass('selected');
//    elm.addClass('selected');
//
//    jQuery('.index-tab-ct').hide();
//    jQuery('.index-tab-ct.userlogs').fadeIn(200);
//  })
//
//  jQuery('.index-page-tabs .tab.notice').live('click',function(){
//    var elm = jQuery(this);
//    if(elm.hasClass('selected')){
//      return;
//    }
//
//    jQuery('.index-page-tabs .tab').removeClass('selected');
//    elm.addClass('selected');
//
//    jQuery('.index-tab-ct').hide();
//    jQuery('.index-tab-ct.notice').fadeIn(200);
//
//  })
//})

//刷新通知计数显示
pie.recount_feed_notice = function(){
  //统计页面上的tip元素数
  var elms = jQuery('.index-tab-ct.notice .tips .tip');


  if(elms.length > 0){

    var tab_elm = jQuery('.page-submenu .with-count.i-am-here');

    if(tab_elm.find('.count').length > 0){
      tab_elm.find('.count').html(elms.length);
    }else{
      tab_elm.append('<div class="count">'+elms.length+'</div>')
    }

  }else{

    jQuery('.page-submenu .with-count.i-am-here .count').remove();
    
  }

  var menu_elm = jQuery('.sub_nav .menu .notices');
  if(menu_elm.find('.count').length > 0){
    var i = parseInt(menu_elm.find('.count').html());
    if(i>0){
      menu_elm.find('.count').html(i-1);
    }else{
      menu_elm.find('.count').remove();
    }
  }else{
    menu_elm.append('<div class="count">'+elms.length+'</div>')
  }


}

//查看更多动态
pie.load(function(){
  jQuery('.index-tab-ct.userlogs .page-list-more').live('click',function(){
    // get /inbox_logs_more  params[:current_id] params[:count]
    var count = jQuery(this).attr('data-count');
    var current_id = jQuery('.index-tab-ct.userlogs .log').last().attr('data-id');
    jQuery.ajax({
      url : '/inbox_logs_more',
      type : 'get',
      data : 'current_id='+current_id+'&count='+count,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        var logs_elm = jQuery(res).find('.log');
        logs_elm.hide();
        jQuery('.index-tab-ct.userlogs .index-userlogs').append(logs_elm);
        logs_elm.fadeIn(200);
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })
})

//查看更多主题
pie.load(function(){
  jQuery('.index-tab-ct.feeds .page-list-more').live('click',function(){
    // get /in_feeds_more  params[:current_id] params[:count]

    var last_vector = jQuery('.index-tab-ct.feeds li').last().attr('data-obj-id');

    var count = jQuery(this).attr('data-count');
    var url = jQuery(this).attr('data-url');

    jQuery.ajax({
      url : url,
      type : 'GET',
      data : {
        'last_vector' : last_vector,
        'count' : count
      },
      success : function(res){
        var lis_elm = jQuery(res).find('li');
        lis_elm.hide();
        jQuery('.index-tab-ct.feeds .newsfeed .mplist.feeds').append(lis_elm);
        lis_elm.fadeIn(200);
      }
    })
  })
})

pie.load(function(){
  jQuery('.user-page-ops a.follow').live('click',function(){
    var user_id = jQuery(this).attr('data-id');

    jQuery.ajax({
      type    : 'POST',
      url     : '/contacts/follow',
      data    : 'user_id='+user_id,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        jQuery('.user-page-ops a.follow').hide();
        jQuery('.user-page-ops a.unfollow').show();
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })

  jQuery('.user-page-ops a.unfollow').live('click',function(){
    var user_id = jQuery(this).attr('data-id');

    jQuery.ajax({
      type    : 'DELETE',
      url     : '/contacts/unfollow',
      data    : 'user_id='+user_id,
      beforeSend : function(){
        pie.show_loading_bar();
      },
      success : function(res){
        jQuery('.user-page-ops a.follow').show();
        jQuery('.user-page-ops a.unfollow').hide();
      },
      complete : function(){
        pie.hide_loading_bar();
      }
    })
  })

})

//隐藏新功能通知
pie.load(function(){
  // put /account/hide_startup
  jQuery('.index-page-new-feature-tip .close').live('click',function(){
    jQuery.ajax({
      url : '/account/hide_new_feature_tips',
      type : 'PUT',
      beforeSend : function(){
        jQuery('.index-page-new-feature-tip').fadeOut(200);
      }
    })
  })
})

//feed排版算法
pie.load(function(){
  var top_l = 0;
  var top_r = 0;

//  jQuery('.newsfeed .list.feeds .feed').each(function(){
//    var feed_elm = jQuery(this);
//    feed_elm.css('position','absolute');
//    if(top_l <= top_r){
//      //排布在左边
//      feed_elm.css('top',top_l);
//      feed_elm.css('left',0);
//      top_l += (feed_elm.height());
//    }else{
//      //排布在右边
//      feed_elm.css('top',top_r);
//      feed_elm.css('left',355);
//      top_r += (feed_elm.height());
//    }
//  })
//
//  jQuery('.newsfeed .list.feeds').css('height',[top_l,top_r].max()).append('<div class="clearfix"></div>');

    jQuery('.newsfeed .list.feeds').append('<div class="listl"></div><div class="listr"></div>');

  jQuery('.newsfeed .list.feeds .feed').each(function(){
    var feed_elm = jQuery(this);
    var listl = jQuery('.newsfeed .list.feeds .listl');
    var listr = jQuery('.newsfeed .list.feeds .listr');

    if(top_l <= top_r){
      //排布在左边
      listl.append(feed_elm);
      top_l += (feed_elm.height());
    }else{
      //排布在右边
      listr.append(feed_elm);
      top_r += (feed_elm.height());
    }
  })
})