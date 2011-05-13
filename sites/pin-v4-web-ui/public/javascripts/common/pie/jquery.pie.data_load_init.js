(function($){
  $(document).ready(function(){
    $('[data-load-url]').each(function(){
      var elm = jQuery(this);
      var url = elm.attr('data-load-url');
      elm.addClass('aj-loading');
      jQuery.ajax({
        type    : 'GET',
        url     : url,
        success : function(res){
          elm.html(res);
          elm.removeClass('aj-loading');
        }
      })
    });
  });
})(jQuery);

pie.load(function(){
  if(pie.env == 'development'){
    var elm = jQuery('<div class="rc5">development</div>');
    elm
      .css('width',210)
      .css('height',40)
      .css('font-size',36)
      .css('line-height','40px')
      .css('opacity','0.618')
      .css('position','absolute')
      .css('padding',10)
      .css('left',10)
      .css('top',20)
      .css('color','white')
      .css('background','black');
    jQuery('body').append(elm);
  }
})

pie.show_loading_bar = function(){
  var elm = jQuery('<div class="ajax-loading-bar"><div class="icon"></div>正在加载…</div>');
  jQuery('body').append(elm);
  return elm;
}

pie.hide_loading_bar = function(){
  jQuery('.ajax-loading-bar').remove();
}

jQuery('body')
  .bind("ajaxStart", function(){
    pie.show_loading_bar();
  })
  .bind("ajaxComplete", function(){
    pie.hide_loading_bar();
  });

pie.load(function(){
  jQuery('.flash-error, .flash-notice, .flash-success').each(function(){
    var elm = jQuery(this);
    elm.fadeOut('fast').fadeIn('fast');
  })
})


