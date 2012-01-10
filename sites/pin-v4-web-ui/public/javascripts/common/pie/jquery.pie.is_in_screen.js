jQuery.fn.is_in_screen = function(){
  var bottom = jQuery(window).height() + jQuery(window).scrollTop();
  var elm_top = this.offset().top;

  return elm_top < bottom;
}