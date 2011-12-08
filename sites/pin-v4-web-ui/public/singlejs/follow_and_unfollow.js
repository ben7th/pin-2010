pie.load(function(){

  var do_follow_btn   = jQuery('.page-index-top .follow-ops .do-follow');
  var do_unfollow_btn = jQuery('.page-index-top .follow-ops .do-unfoll');

  do_follow_btn.bind('click',function(){
    var elm = jQuery(this);
    var user_id = elm.domdata('id');

    jQuery.ajax({
      url : '/contacts/follow_mindpin',
      type : 'POST',
      data : 'user_id='+user_id,
      success : function(){
        do_follow_btn.hide();
        do_unfollow_btn.fadeIn(200);
      }
    })
  })

  do_unfollow_btn.bind('click',function(){
    var elm = jQuery(this);
    var user_id = elm.domdata('id');

    jQuery.ajax({
      url : '/contacts/unfollow',
      type : 'DELETE',
      data : 'user_id='+user_id,
      success : function(){
        do_follow_btn.fadeIn(200);
        do_unfollow_btn.hide();
      }
    })
  })

})