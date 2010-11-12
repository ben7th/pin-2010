(function($) {

  function init_form_style(){
    // 添加classname到对应的form field
    $('html body input[type="text"], html body input[type="password"]').addClass("text");
    $('input[type="submit"]').addClass("submit");
    $('input[type="checkbox"]').addClass("checkbox");

    // 给校验中出现error的字段添加样式
    $("form .fieldWithErrors").closest("div.field").addClass("error")

    // -- make error notice the same width as error field
    $("form .fieldWithErrors input, form .fieldWithErrors textarea").each(function(i, field){
      width = $(field).width();
      $(field).closest('div.field').find('.formError').width(width);
    });
  }

  jQuery(document).ready(init_form_style);
  jQuery(document).bind('reveal.facebox',init_form_style)
})(jQuery);

(function($) {
  jQuery(document).ready(function() {
    // -- add active class to active elements
    $("form select, form .text, form textarea")
      .live('focus',function( ){
        $(this).closest("div.field").addClass("active");
        $(this).closest("fieldset").addClass("active");
      })
      .live('blur',function( ){
        $(this).closest("div.field").removeClass("active");
        $(this).closest("fieldset").removeClass("active");
      });

    $("input[type='submit']")
      .live('mousedown',function(){$(this).addClass("mousedown")})
      .live("mouseup mouseleave",function(){$(this).removeClass("mousedown")});
  });
})(jQuery);