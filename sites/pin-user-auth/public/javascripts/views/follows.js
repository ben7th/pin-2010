pie.load(function(){
  jQuery(".follow_btn").each(function(){
    var follow_a_btn = jQuery(this).find("a");
    follow_a_btn.bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();
      var user_id = follow_a_btn.attr("data-user-id");
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
  });

  jQuery(".unfollow_btn").each(function(){
    var unfollow_a_btn = jQuery(this).find("a");
    unfollow_a_btn.bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();
      var user_id = unfollow_a_btn.attr("data-user-id");
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

});