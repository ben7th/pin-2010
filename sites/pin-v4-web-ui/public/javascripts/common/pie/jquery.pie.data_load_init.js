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

pie.load(function(){
  jQuery('.flash-error, .flash-notice, .flash-success').each(function(){
    var elm = jQuery(this);
    elm.fadeOut('fast').fadeIn('fast');
  })
})


