pie.load(function(){
  jQuery('.binded-account-info .misc .update a').live('click',function(){
    
    jQuery('.binded-account-info .misc').addClass('up');
    jQuery.ajax({
      url : '/bind_other_site/update_bind_renren_info',
      type : 'POST',
      success : function(res){
        var elm = jQuery(res);
        jQuery('.binded-account-info').html(elm.html());
      },
      error : function(res){
        alert(res.responseText)
      }
    })
  });
})


