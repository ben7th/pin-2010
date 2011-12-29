// 获取或设置元素上的 data- 属性
(function($) {
    $.fn.domdata = function(name, data) {
      var elm = jQuery(this);
      var real_name = 'data-'+name;

      return elm.attr(real_name, data)
    }
})(jQuery);