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
  if(jQuery.string(window.location.host).startsWith('dev.')){
    jQuery('<div>DEVELOPMENT</div>')
      .css('height',      40)
      .css('font-size',   36)
      .css('line-height', '40px')
      .css('position',    'fixed')
      .css('padding',     10)
      .css('left',        5)
      .css('top',         5)
      .css('color',       '#444')
      .css('background',  'rgba(255,255,255,0.6)')
      .css('z-index',     99)
      .appendTo(document.body);
  }
})

pie.show_page_overlay = function(opacity){
  var o = opacity || 0.4;
  jQuery('<div class="page-pie-overlay"></div>')
    .css('height', jQuery(window).height())
    .css('opacity', 0)
    .appendTo(document.body)
    .animate({'opacity': o}, 300);
}

pie.hide_page_overlay = function(){
  jQuery('.page-pie-overlay').remove();
}

pie.load(function(){
  jQuery('.flash-error, .flash-notice, .flash-success').each(function(){
    var elm = jQuery(this);
    elm.fadeOut('fast').fadeIn('fast');
  })
})

//去掉IE6 7的虚线框
pie.load(function(){
  if(jQuery.browser.msie){
    var v = jQuery.browser.version;
    if(v=='7.0' || v=='6.0'){
      jQuery('a').attr('hideFocus','hidefocus');
    }
  }
})