(function($) {
  jQuery(document).ready(function() {
    $("button, .minibutton")
      .live("mousedown",function(){$(this).addClass("mousedown")})
      .live("mouseup mouseleave",function(){$(this).removeClass("mousedown")});
  });
})(jQuery);
