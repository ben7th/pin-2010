// 表单项 focus 和 blur 事件绑定
pie.load(function() {
  // -- add active class to active elements
  jQuery('select, textarea, input')
    .live('focus', function(){ jQuery(this).addClass("active") })
    .live('blur',  function(){ jQuery(this).removeClass("active") });

  jQuery('input[type=submit], a')
    .live('mousedown',          function(){ jQuery(this).addClass("mousedown") })
    .live("mouseup mouseleave", function(){ jQuery(this).removeClass("mousedown") });
});