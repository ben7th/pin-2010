pie.load(function(){
  // 更新新浪微博关联账号信息
  jQuery('.page-binded-account-info .misc .update a').live('click',function(){

    jQuery('.page-binded-account-info .misc').addClass('up');

    jQuery.ajax({
      url : '/account/tsina/update_info',
      type : 'POST',
      success : function(res){
        var elm = jQuery(res);
        jQuery('.page-binded-account-info').html(elm.html());
      },
      error : function(res){
        //jQuery('.page-binded-account-info .meta').html(res.responseText);
        jQuery('.page-binded-account-info .misc').removeClass('up');
      }
    })
  });
})