//记录频道dom坐标范围，拖拽时判断用
pie.get_channel_dom_scopes = function(){
  window.channel_dom_scopes = [];
  jQuery('.page-channels-set .channel').each(function(){
    var elm = jQuery(this);
    var offset = elm.offset();
    var height = elm.outerHeight();
    var width = elm.outerWidth();
    var scope = {
      elm : elm,
      top : offset.top,
      left : offset.left,
      bottom : offset.top + height,
      right : offset.left + width
    }
    window.channel_dom_scopes.push(scope);
  })
}
pie.load(function(){
  pie.get_channel_dom_scopes();
})

pie.get_following = function(user_id){
  return jQuery('.page-followings-set .following[data-id='+user_id+']');
}
pie.following_ids_remove_from_channel = function(user_id,channel_id){
  var u_elm = pie.get_following(user_id)
  var ch_ids = u_elm.attr('data-channel-ids').split(',');
  var new_ch_ids = ch_ids.without(channel_id);
  u_elm.attr('data-channel-ids',new_ch_ids.join(','));
  if(new_ch_ids.length == 0){
    u_elm.fadeOut(200,function(){u_elm.remove()});
  }
}
pie.following_ids_add_to_channel = function(user_id,channel_id){
  var u_elm = pie.get_following(user_id)
  var ch_ids = u_elm.attr('data-channel-ids').split(',');
  ch_ids.push(channel_id);
  u_elm.attr('data-channel-ids',ch_ids.uniq().join(','));
}
pie.is_following_in_channel = function(user_id,channel_id){
  var u_elm = pie.get_following(user_id)
  var ch_ids = u_elm.attr('data-channel-ids').split(',');
  return ch_ids.include(channel_id);
}

pie.get_channel = function(channel_id){
  return jQuery('.page-channels-set .channel[data-id='+channel_id+']');
}

//鼠标覆盖用户，高亮频道
pie.do_channel_following_hover = function(channel_id){
  pie.get_channel(channel_id).addClass('following-hover')
    .find('.meta').stop().animate({
      'background-color':'#4797CF'
    },500);
}
pie.clear_channel_following_hover = function(){
  var elm = jQuery('.page-channels-set .channel.following-hover')
  elm.removeClass('following-hover')
    .find('.meta').stop().animate({
      'background-color':'#666666'
    },500,function(){
      elm.find('.meta').css('background-color','');
    });
}

pie.channel_elm_can_be_mouseover = function(elm){
  return !window.is_dragging && !elm.hasClass('dd-hover');
}
//鼠标覆盖频道
pie.do_channel_mousehover = function(channel_elm){
  channel_elm.find('.users').fadeIn(300);
  channel_elm.find('.meta').animate({
    'height':20,
    'background-color':'#444444'
  },200)
}
pie.cancel_channel_mouserover = function(channel_elm){
  channel_elm.find('.users').fadeOut(300);
  channel_elm.find('.meta').animate({
    'height':50,
    'background-color':'#666666'
  },200,function(){
    channel_elm.find('.meta').css('background-color','');
  })
}

//拖拽时拖拽目标覆盖频道
pie.do_channel_dd_hover = function(channel_elm){
  if(!channel_elm.hasClass('dd-hover')){
    channel_elm.addClass('dd-hover');

    channel_elm.find('.users').fadeIn(300);
    channel_elm.find('.meta').animate({
      'height':20
    },200);
  }
}
pie.clear_channel_dd_hover_except = function(except_channel_id){
  jQuery('.page-channels-set .channel.dd-hover').each(function(){
    var elm = jQuery(this);
    if(elm.attr('data-id') != except_channel_id){
      elm.find('.users').fadeOut(300);
      elm.find('.meta').animate({
        'height':50
      },200,function(){
        elm.find('.meta').css('height','');
      });
      elm.removeClass('dd-hover');
    }
  });
}


pie.is_XY_in_scopes = function(x,y){
  var re = false;

  window.channel_dom_scopes.each(function(scope){
    var left = scope.left;
    var top = scope.top;
    var right = scope.right;
    var bottom = scope.bottom;
    var elm = scope.elm;

    if( x > left && x < right && y > top && y < bottom){
      re = elm;
      throw $break;
    }
  })

  return re;
}

/*以上是各种泛用事件和动画效果函数*/

pie.load(function(){
  //根据id取得一个channel的jq

  //用户点击切换选中状态
  jQuery(document).delegate('.page-followings-set .following','click',function(){
    var elm = jQuery(this);
    elm.toggleClass('selected');
  })

  //鼠标指向用户的时候，显著显示该用户所在的频道
  jQuery(document).delegate('.page-followings-set .following','mouseenter',function(){
    var elm = jQuery(this);
    var channel_ids = elm.attr('data-channel-ids').split(',');

    channel_ids.each(function(channel_id){
      pie.do_channel_following_hover(channel_id);
    })
  })
  .delegate('.page-followings-set .following','mouseleave',function(){
    pie.clear_channel_following_hover();
  })
})

//channel上的鼠标浮动
pie.load(function(){
  jQuery(document).delegate('.page-channels-set .channel','mouseenter',function(){
    var elm = jQuery(this);
    window.channel_hover = elm;

    if(pie.channel_elm_can_be_mouseover(elm)){
      setTimeout(function(){
        if(window.channel_hover == elm){
          pie.do_channel_mousehover(elm)
        }
      },200)
    }
  })
  .delegate('.page-channels-set .channel','mouseleave',function(){
    var elm = jQuery(this);
    window.channel_hover = false;

    if(pie.channel_elm_can_be_mouseover(elm)){
      pie.cancel_channel_mouserover(elm)
    }
  })
});


pie.load(function(){
  //频道内用户拖拽
  jQuery(document).delegate('.page-channels-set .channel .users .avatar','mousedown',function(evt){
    var elm = jQuery(this);
    var current_channel_elm = elm.closest('.channel');

    //初始坐标
    var cX = evt.pageX;
    var cY = evt.pageY;

    //过程坐标
    var newX = cX;
    var newY = cY;

    //移动距离
    var distanceX = 0;
    var distanceY = 0;
    var sqrd = 0;

    //放置拖拽过程dom的dom
    var dd_pad_elm = jQuery('<div></div>')
      .css('position','absolute')
      .css('left',0).css('top',0);

    window.is_dragging = true;
    
    var movefunc = function(evt){
      newX = evt.pageX;
      newY = evt.pageY;

			distanceX = newX - cX;
      distanceY = newY - cY;
      sqrd = distanceX*distanceX + distanceY*distanceY;

      if(jQuery('.page-channel-avatar-dd').length == 0){
        if(sqrd > 25){

          //原始拖拽对象定位坐标
          var ioffset = elm.offset();
          var ileft = ioffset.left;
          var itop = ioffset.top;

          var dd_elm = elm.clone();

          dd_elm
            .append('<div class="icon">删除</div>')
            .attr('data-ileft',ileft).attr('data-itop',itop)
            .addClass('page-channel-avatar-dd')
            .css('left',ileft).css('top',itop);
            
          dd_pad_elm.append(dd_elm);
          jQuery('body').append(dd_pad_elm);
          
          elm.css('opacity',0.2);
        }
      }else{
        dd_pad_elm.css('left',distanceX).css('top',distanceY);

        //判断是否在范围内
        var scope_elm = pie.is_XY_in_scopes(newX, newY);

        if(scope_elm){
          //拖拽到了某个频道目标上
          //首先，清理所有的覆盖效果
          pie.clear_channel_dd_hover_except(scope_elm.attr('data-id'));
          //然后，清理“正被移出”效果
          current_channel_elm.removeClass('avatar-moveout');
          dd_pad_elm.find('.page-channel-avatar-dd').removeClass('will-remove').removeClass('will-putin');

          //两种情况，第一种，拖拽到本频道
          //什么都不做
          //第二种，拖拽到其他频道

          if(scope_elm.attr('data-id') != current_channel_elm.attr('data-id')){
            pie.do_channel_dd_hover(scope_elm);
            dd_pad_elm.find('.page-channel-avatar-dd').addClass('will-putin');
          }
        }else{
          //未拖拽到任何频道目标上
          //清理所有覆盖效果
          pie.clear_channel_dd_hover_except(null);
          //添加“正被移出”效果
          current_channel_elm.addClass('avatar-moveout');
          dd_pad_elm.find('.page-channel-avatar-dd').removeClass('will-remove').removeClass('will-putin');
          dd_pad_elm.find('.page-channel-avatar-dd').addClass('will-remove');
        }
      }
    }

    //拖拽过程函数
    jQuery(document).bind('mousemove.dragdrop1',movefunc);

    //拖拽中止
    jQuery(document).bind('mouseup.dragdrop2',function(){
      //清除事件绑定
      jQuery(document).unbind('.dragdrop1');
      jQuery(document).unbind('.dragdrop2');

      var done = false;

      var moveout_elm = jQuery('.page-channels-set .channel.avatar-moveout');
      if(moveout_elm.length == 1){
        done = true;
        pie.remove_a_user_from_channel(moveout_elm, elm);
        setTimeout(function(){
          pie.cancel_channel_mouserover(current_channel_elm);
        },400)
      }

      var dd_hover_elm = jQuery('.page-channels-set .channel.dd-hover');
      if(dd_hover_elm.length == 1){
        done = true;
        pie.move_a_user_to_channel(dd_hover_elm, elm);
        setTimeout(function(){
          pie.cancel_channel_mouserover(current_channel_elm);
        },400)
      }

      if(!done){
        dd_pad_elm.delay(50).animate({
          'left':0,'top':0
        },200,function(){
          dd_pad_elm.remove();
          elm.css('opacity',1);
          pie.cancel_channel_mouserover(current_channel_elm);
        })
      }else{
        dd_pad_elm.remove();
      }

      jQuery('.page-channels-set .channel').removeClass('dd-hover').removeClass('avatar-moveout');

      window.is_dragging = false;
    })

  })
})

pie.remove_a_user_from_channel = function(channel_elm, user_avatar_elm){
  user_avatar_elm.fadeOut(200,function(){user_avatar_elm.remove();})
  var ucount_elm = channel_elm.find('.ucount');
  ucount_elm.html(parseInt(ucount_elm.html())-1);

  var offset = ucount_elm.offset();

  var ucount_aj = jQuery('<div class="page-ucount-aj delete">-1</div>');
  jQuery('body').append(ucount_aj);
  ucount_aj.css('top',offset.top).css('left',offset.left)
    .delay(100).animate({'top':'-=30px'}).fadeOut(200,function(){
      ucount_aj.remove();
    })

  var user_id = user_avatar_elm.attr('data-id');
  var channel_id = channel_elm.attr('data-id');
  pie.following_ids_remove_from_channel(user_id,channel_id);

  // 将一个人移出频道
  // put
  // params[:user_id]
  jQuery.ajax({
    url : '/channels/'+channel_id+'/remove',
    type : 'PUT',
    data : 'user_id='+user_id
  })
}

pie.move_a_user_to_channel = function(channel_elm, user_avatar_elm){
  user_avatar_elm.css('opacity',1);

  var user_id = user_avatar_elm.attr('data-id');
  var channel_id = channel_elm.attr('data-id');

  if(!pie.is_following_in_channel(user_id, channel_id)){
    var ucount_elm = channel_elm.find('.ucount');
    ucount_elm.html(parseInt(ucount_elm.html())+1);


    var offset = ucount_elm.offset();

    var ucount_aj = jQuery('<div class="page-ucount-aj add">+1</div>');
    jQuery('body').append(ucount_aj);
    ucount_aj.css('top',offset.top).css('left',offset.left)
      .delay(100).animate({'top':'-=30px'}).fadeOut(200,function(){
        ucount_aj.remove();
      })

    channel_elm.find('.users').prepend(user_avatar_elm.clone().hide().fadeIn())

    pie.following_ids_add_to_channel(user_id,channel_id);

    //post /channels/:id/add_users
    //params[:user_ids] = "1,2,3,4,5"
    jQuery.ajax({
      url : '/channels/'+ channel_id + '/add_users',
      data : 'user_ids='+user_id,
      type : 'POST'
    })
  }
};

pie.load(function(){
  Element.makeUnselectable($$('.cell')[0]);

  //following拖拽
  jQuery(document).delegate('.page-followings-set .following','mousedown',function(evt){
    var elm = jQuery(this);
    
    //初始坐标
    var cX = evt.pageX;
    var cY = evt.pageY;

    //过程坐标
    var newX = cX;
    var newY = cY;

    //移动距离
    var distanceX = 0;
    var distanceY = 0;
    var sqrd = 0;

    //放置拖拽过程dom的dom
    var dd_pad_elm = jQuery('<div></div>')
      .css('position','absolute')
      .css('left',0).css('top',0);
    var drag_target_elms;

    window.is_dragging = true;

    var movefunc = function(evt){
      newX = evt.pageX;
      newY = evt.pageY;

			distanceX = newX - cX;
      distanceY = newY - cY;
      sqrd = distanceX*distanceX + distanceY*distanceY;

      if(jQuery('.page-following-dd').length == 0){
        if(sqrd > 25){
          //选中拖拽原始定位对象
          elm.addClass('selected').css('z-index','100');

          //获得拖拽原始对象dom
          drag_target_elms = jQuery('.page-followings-set .following.selected');

          //原始拖拽对象定位坐标
          var ori_offset = elm.offset();
          var ori_left = ori_offset.left;
          var ori_top = ori_offset.top;

          //计数dom
          var length = drag_target_elms.length;
          var count_elm;
          if(length > 1){
            count_elm = jQuery('<div class="page-dragdrop-user-count">'+length+'个人</div>');
            count_elm.css('left',ori_left+90).css('top',ori_top+5).hide();
            dd_pad_elm.append(count_elm);
            count_elm.fadeIn(300);
          }

          //复制若干dom
          drag_target_elms.each(function(index){
            var ielm = jQuery(this);
            var offset = ielm.offset();
            var ileft = offset.left;
            var itop = offset.top;

            var dd_elm = ielm.clone();
            var rotate = ielm.attr('data-id') == elm.attr('data-id') ? 0 : 6-12*Math.random();
            var loff = ielm.attr('data-id') == elm.attr('data-id') ? 0 : 4-8*Math.random();
            var toff = ielm.attr('data-id') == elm.attr('data-id') ? 0 : 4-8*Math.random();
            dd_elm
              .attr('data-ileft',ileft).attr('data-itop',itop)
              .addClass('page-following-dd').addClass('selected')
              .css('left',ileft).css('top',itop).css('opacity',0.8)
              .delay(200)
              .animate({
                'left':ori_left + loff,
                'top':ori_top + toff,
                'rotate': rotate
              },300)
            dd_pad_elm.append(dd_elm);
          })
          
          drag_target_elms.css('opacity',0.5);
          jQuery('body').append(dd_pad_elm);
        }
      }else{
        dd_pad_elm.css('left',distanceX).css('top',distanceY);

        //判断是否在范围内
        var scope_elm = pie.is_XY_in_scopes(newX, newY);

        if(scope_elm){
          //拖拽到了某个频道目标上
          //首先，清理所有的覆盖效果
          pie.clear_channel_dd_hover_except(scope_elm.attr('data-id'));

          pie.do_channel_dd_hover(scope_elm);
          dd_pad_elm.find('.page-channel-avatar-dd').addClass('will-putin');
        }else{
          //未拖拽到任何频道目标上
          //清理所有覆盖效果
          pie.clear_channel_dd_hover_except(null);
        }
      }
    }

    //拖拽过程函数
    jQuery(document).bind('mousemove.dragdrop1',movefunc);

    //拖拽中止
    jQuery(document).bind('mouseup.dragdrop2',function(){
      //清除事件绑定
      jQuery(document).unbind('.dragdrop1');
      jQuery(document).unbind('.dragdrop2');

      var done = false;

      //触发请求事件
      var dd_hover_elm = jQuery('.page-channels-set .channel.dd-hover');
      if(dd_hover_elm.length == 1){
        done = true;
        
        var channel_id = dd_hover_elm.attr('data-id');
        var user_ids = []
        dd_pad_elm.find('.page-following-dd').each(function(){
          user_ids.push(jQuery(this).attr('data-id'));
        })

        var add_count = 0;
        user_ids.each(function(user_id){
          if(!pie.is_following_in_channel(user_id,channel_id)){
            pie.following_ids_add_to_channel(user_id,channel_id);
            var avatar_elm = pie.get_following(user_id).find('.avatar-s').clone().removeClass('avatar-s').addClass('avatar');
            dd_hover_elm.find('.users').prepend(avatar_elm.hide().fadeIn());
            add_count += 1;
          }
        })

        if(add_count>0){
          var ucount_elm = dd_hover_elm.find('.ucount');
          ucount_elm.html(parseInt(ucount_elm.html())+add_count);

          var offset = ucount_elm.offset();

          var ucount_aj = jQuery('<div class="page-ucount-aj add">+'+add_count+'</div>');
          jQuery('body').append(ucount_aj);
          ucount_aj.css('top',offset.top).css('left',offset.left)
            .delay(100).animate({'top':'-=30px'}).fadeOut(200,function(){
              ucount_aj.remove();
            })
        }

        jQuery('.page-dragdrop-user-count').remove();
        dd_pad_elm.remove();
        jQuery('.page-followings-set .following').removeClass('selected');

        setTimeout(function(){
          pie.clear_channel_dd_hover_except(null);
        },400);

        //post /channels/:id/add_users
        //params[:user_ids] = "1,2,3,4,5"
        jQuery.ajax({
          url : '/channels/'+ channel_id + '/add_users',
          data : 'user_ids='+user_ids,
          type : 'POST'
        })


      }else{
        //将dom移动回原位并隐藏dom
        jQuery('.page-dragdrop-user-count').remove();
        dd_pad_elm.find('.page-following-dd').each(function(){
          var dd_elm = jQuery(this);
          var ileft = parseInt(dd_elm.attr('data-ileft'));
          var itop =parseInt(dd_elm.attr('data-itop'));
          dd_elm.delay(100).animate({
            'left':ileft - distanceX,
            'top':itop - distanceY,
            'rotate': 0
          },300,function(){
            dd_pad_elm.remove();
          })
        });
      }

      if(!done) jQuery('.page-channels-set .channel').removeClass('dd-hover');
      
      if(drag_target_elms){
        drag_target_elms.css('opacity',1).css('z-index','1');
      }

      window.is_dragging = false;
    })
  })
})