(function(){
  jQuery('body').append("<div id='tip' class='hide'></div>")
  jQuery("#tip").css(
    {
      position:'absolute',
      color:'#222',
      'background-color':'#CCCCCC',
      padding:'4px'
    }
  );
})();
jQuery(".delete_comment").live('click',function(){
  var dc_div_clone = jQuery(this).next('.delete_confirm').clone();
  jQuery('#tip').text("");
  dc_div_clone.appendTo(jQuery('#tip'));
  jQuery("#tip .submit_confirm").click(function(){
    jQuery("#tip").text("");
    jQuery('#tip').addClass("hide");
  });
  jQuery("#tip .cancel_confirm").click(function(){
    jQuery("#tip").text("");
    jQuery('#tip').addClass("hide");
  });
  dc_div_clone.removeClass("hide");


  var offset = jQuery(this).offset()
  var left = offset["left"]
  var top = offset["top"] - 10
  jQuery('#tip').css({left:left + "px",top:top + "px"})
  jQuery('#tip').removeClass("hide");
});




