pie.load(function(){
  
  jQuery('.follow_btn a').live('click',function(){
    var user_id = jQuery(this).attr('data-user-id');
    jQuery.ajax({
      type    : 'POST',
      url     : '/contacts/follow',
      data    : 'user_id='+user_id,
      success : function(res){
        jQuery('.follow_btn'+'.btn_'+user_id).hide();
        jQuery('.unfollow_btn'+'.btn_'+user_id).show();
      }
    })
  });

  jQuery('.unfollow_btn a').live('click',function(){
    var user_id = jQuery(this).attr('data-user-id');
    jQuery.ajax({
      type    : 'DELETE',
      url     : '/contacts/unfollow',
      data    : 'user_id='+user_id,
      success : function(res){
        jQuery('.follow_btn'+'.btn_'+user_id).show();
        jQuery('.unfollow_btn'+'.btn_'+user_id).hide();
      }
    })
  });

});