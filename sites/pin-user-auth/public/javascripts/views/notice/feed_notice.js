pie.load(function(){

  var feed_tip_elm = jQuery('.new-feed-tip');

  var tip_elm = jQuery(
    '<div class="misc-tip">'+
      '<div class="fans"><span class="num">1</span> 个新读者，</span><a href = "'+
        pie.pin_url_for('pin-user-auth',pie.current_user_id+'/fans')
      +'">点击查看~</a></div>'+
      '<div class="comments"><span class="num">1</span> 条新回应，<a href="'+
        pie.pin_url_for('pin-user-auth','received_comments')
      +'">点击查看~</a></div>'+
      '<div class="quotes"><span class="num">1</span> 次被传播，<a href="'+
        pie.pin_url_for('pin-user-auth','quoted_me_feeds')
      +'">点击查看~</a></div>'+
      '<div class="todos"><span class="num">1</span> 个话题邀请，<a href="'+
        pie.pin_url_for('pin-user-auth','todos')
      +'">点击查看~</a></div>'+
    '</div>'
  )

  jQuery(window).scroll(function(){
    set_tip_top();
  });

  var set_tip_top = function(){
    var s_top = jQuery(window).scrollTop();
    var top = 20;
    if(s_top < 19){
      top = top - s_top;
    }else{
      top = 1;
    }
    tip_elm.css('top',top);
  }

  var runner = new PeriodicalExecuter(function(){
    jQuery.ajax({
      url     : "/newsfeed/new_count",
      success : function(res){
        show_tip(res);
      },
      error : function(){
        tip_elm.hide();
      }
    });
  },15);

  var show_tip = function(info){
    var feeds_count = info.feeds;
    if(feeds_count > 0){
      feed_tip_elm.slideDown(100);
    };


    set_tip_top();
    var fans_count = info.fans;
    if(fans_count > 0){
      tip_elm.addClass('show-fans');
      tip_elm.find('.fans .num').html(fans_count);
      jQuery('body .page-content').append(tip_elm);
    }else{
      tip_elm.removeClass('show-fans')
    }

    var comments_count = info.comments;
    if(comments_count > 0){
      tip_elm.addClass('show-comments');
      tip_elm.find('.comments .num').html(comments_count);
      jQuery('body .page-content').append(tip_elm);
    }else{
      tip_elm.removeClass('show-comments')
    }

    var quotes_count = info.quotes;
    if(quotes_count > 0){
      tip_elm.addClass('show-quotes');
      tip_elm.find('.quotes .num').html(quotes_count);
      jQuery('body .page-content').append(tip_elm);
    }else{
      tip_elm.removeClass('show-quotes')
    }

    var todos_count = info.todos;
    if(todos_count > 0){
      tip_elm.addClass('show-todos');
      tip_elm.find('.todos .num').html(todos_count);
      jQuery('body .page-content').append(tip_elm);
    }else{
      tip_elm.removeClass('show-todos')
    }
  }
  
  show_tip(pie.misc_tip_info);

  feed_tip_elm.find('a').live('click',function(){
    feed_tip_elm.addClass('aj-loading');
    
    var newest_page_feed_id = jQuery('.mplist.feeds li.feed.mpli .f').attr('data-id') || '';
    
    jQuery.ajax({
      url     : '/newsfeed/get_new_feeds',
      data    : 'after=' + newest_page_feed_id,
      success : function(res){
        var children_lis = jQuery(res).children();
        jQuery('.mplist.feeds').prepend(children_lis);
        children_lis.hide().slideDown(400);
      }.bind(this),
      complete : function(res){
        feed_tip_elm.removeClass('aj-loading').hide();
      }.bind(this)
    })
  })
    
});