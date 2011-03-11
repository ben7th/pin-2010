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


