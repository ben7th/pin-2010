pie.WEIBO = {};

jQuery.extend(pie.WEIBO, {
  show_olist_overlay : function(){
    jQuery('<div class="page-web-weibo-overlay"></div>')
      .css('height', jQuery(window).height())
      .css('opacity', 0)
      .appendTo(document.body)
      .animate({'opacity': 0.4}, 600);
  },

  remove_olist_overlay : function(){
    jQuery('.page-web-weibo-overlay').remove();
  },

  // 绑定鼠标移入移出事件
  bind_hover_intent_event : function(elms){
    var WEIBO = pie.WEIBO;

    elms.hoverIntent({
      sensitivity: 10,
      interval: 250,
      over: function(){
        var elm = jQuery(this);
        var status_elm = elm.closest('.status');

        WEIBO.show_olist_overlay();
        status_elm.addClass('boxhover');
      },
      timeout: 0,
      out: function(){
        var elm = jQuery(this);
        var status_elm = elm.closest('.status');

        WEIBO.remove_olist_overlay();
        status_elm.removeClass('boxhover');
      }
    });
  }
});

jQuery.fn._is_in_screen = function(){
  var bottom = jQuery(window).height() + jQuery(window).scrollTop();
  var elm_top = this.offset().top;

  return elm_top < bottom;
}

pie.load(function(){
  var WEIBO = pie.WEIBO;
  
  var statuses_elm  = jQuery('.page-web-weibo-statuses').fadeIn(1000);
  var load_more_elm = jQuery('a.page-web-weibo-load-more').fadeIn(1000);

  // 全局排列
  statuses_elm.isotope({
    itemSelector : '.gi',
    masonry : { columnWidth : 186 },
    transformsEnabled: false
  });

  // ------ LOAD PHOTOS
  
  var lazy_load_photos = function(){
    statuses_elm.find('.status .photo:not(.-img-loaded-)').each(function(){
      var elm = jQuery(this);
      if(elm._is_in_screen()){
        pie.load_cut_img(elm.data('src'), elm, elm);
        elm.addClass('-img-loaded-')
      }
    });

    statuses_elm.find('.status .avatar:not(.-img-loaded-)').each(function(){
      var elm = jQuery(this);
      if(elm._is_in_screen()){
        jQuery('<img/>').attr('src',elm.data('src')).hide().fadeIn(200).appendTo(elm);
        elm.addClass('-img-loaded-')
      }
    })
  }

  lazy_load_photos();
  jQuery(window).bind('scroll', lazy_load_photos);

  

  // ------------------- 翻页组件
  var load_more = function(){
    if(load_more_elm.hasClass('loading')) return;

    var max_id = jQuery('.page-web-weibo-statuses .status').last().data('mid') - 1;
    var load_url = jQuery(this).data('url');

    pie.dont_show_loading_bar(); // 防止显示全局ajaxloadingbar
    jQuery.ajax({
      url  : load_url,
      type : 'GET',
      data : { 'max_id' : max_id },
      beforeSend : function(){
        load_more_elm.addClass('loading').find('span').html('LOADING');
      },
      success : function(res){
        var new_elms = jQuery(res);
        jQuery('.page-web-weibo-statuses').append(new_elms).isotope('appended', new_elms);
        
        lazy_load_photos();
        WEIBO.bind_hover_intent_event(new_elms.find('.box'))
      },
      complete : function(){
        load_more_elm.removeClass('loading').find('span').html('LOAD MORE');
      }
    });
  }
  
  load_more_elm.live('click', load_more);
  
  jQuery(window).bind('scroll', function(){
    if(load_more_elm._is_in_screen()){
      load_more();
    }
  });

  // ----------- 移入移出事件绑定
  WEIBO.bind_hover_intent_event(statuses_elm.find('.status .box'));
})


// 微博收集组件
pie.load(function(){

  var cart_count_elm = jQuery('.page-web-weibo-toolbar .cart .count');
  var _left_cc = 56;
  var _top_cce = 237;

  jQuery('.page-web-weibo-statuses .status .cart .add').live('click',function(){
    // /weibo/cart/add
    var elm        = jQuery(this);
    var cart_elm   = elm.closest('.cart')
    var status_elm = elm.closest('.status');
    var mid        = status_elm.data('mid');

    var offset = elm.offset();
    var l1= offset.left;
    var t1= offset.top - jQuery(window).scrollTop();

    var ani_elm = jQuery('<div class="page-web-weibo-cart-add-ani">1</div>').appendTo(document.body);
    ani_elm
      .css({
        'left' : l1,
        'top'  : t1
      })
      .animate({
        'left'    : [_left_cc,'easeInSine'],
        'top'     : [_top_cce,'easeInExpo'],
        'opacity' : 0.6
      }, 1000, function(){
        cart_count_elm.html(parseInt(cart_count_elm.html())+1);
        ani_elm.remove()
      })

    pie.dont_show_loading_bar(); // 防止显示全局ajaxloadingbar
    jQuery.ajax({
      url  : '/weibo/cart/add',
      data : {'mid':mid},
      type : 'POST',
      beforeSend : function(){
        cart_elm.addClass('loading');
      },
      success : function(){
        cart_elm.addClass('added');
      },
      complete : function(){
        cart_elm.removeClass('loading');
      }
    })
  });

})