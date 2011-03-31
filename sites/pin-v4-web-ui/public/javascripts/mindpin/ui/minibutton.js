(function($) {
  jQuery(document).ready(function() {
    $("button, .minibutton, a.button, a.subbtn, .button a")
      .live("mousedown",function(){$(this).addClass("mousedown")})
      .live("mouseup mouseleave",function(){$(this).removeClass("mousedown")});
  });
})(jQuery);
