//关注以及取消关注
pie.load(function(){

  //关注时，出现浮动菜单，要求选择一到多个频道
  jQuery('.user-follow-op a.follow').live('click',function(){
    var elm = jQuery(this);
    var op_elm = elm.closest('.user-follow-op')
    var user_id = op_elm.attr('data-id');
    var selector_elm = op_elm.find('.channel-selector');

    selector_elm.fadeIn(200);
  })

  jQuery('.user-follow-op .channel-selector .ch').live('click',function(){
    var elm = jQuery(this);
    var op_elm = elm.closest('.user-follow-op');
    var user_id = op_elm.attr('data-id');
    var channel_id = elm.attr('data-id');

    pie.log(user_id,channel_id);

    op_elm.find('.channel-selector').fadeOut(100);

    jQuery.ajax({
      type    : 'POST',
      url     : '/contacts/follow',
      data    : 'user_id='+user_id+'&channel_ids='+channel_id,
      success : function(res){
        jQuery('.user-follow-op a.follow').hide();
        jQuery('.user-follow-op a.unfollow').show();
      }
    })
  })

  jQuery('.user-follow-op a.unfollow').live('click',function(){
    var elm = jQuery(this);
    var op_elm = elm.closest('.user-follow-op')
    var user_id = op_elm.attr('data-id');

    jQuery.ajax({
      type    : 'DELETE',
      url     : '/contacts/unfollow',
      data    : 'user_id='+user_id,
      success : function(res){
        jQuery('.user-follow-op a.follow').show();
        jQuery('.user-follow-op a.unfollow').hide();
      }
    })
  })

})