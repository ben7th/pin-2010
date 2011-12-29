pie.show_loading_bar = function(){
  var elm = jQuery('<div class="ajax-loading-bar"><div class="icon"></div>正在加载…</div>');
  jQuery('body').append(elm);
  return elm;
}

pie.hide_loading_bar = function(){
  jQuery('.ajax-loading-bar').remove();
}

pie.dont_show_loading_bar = function(){
  window.DONT_SHOW_AJAX_LOADING_BAR = true;
}

jQuery('body')
  .bind("ajaxStart", function(){
    if(true == window.DONT_SHOW_AJAX_LOADING_BAR) return;
    pie.show_loading_bar();
  })
  .bind("ajaxComplete", function(){
    window.DONT_SHOW_AJAX_LOADING_BAR = false;
    pie.hide_loading_bar();
  });