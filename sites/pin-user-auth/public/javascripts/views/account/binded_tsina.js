pie.load(function(){
  jQuery('.binded-account-info .misc .update a').live('click',function(){
    
    jQuery('.binded-account-info .misc').addClass('up');
    jQuery.ajax({
      url : '/bind_other_site/update_bind_tsina_info',
      type : 'POST',
      success : function(res){
        var elm = jQuery(res);
        jQuery('.binded-account-info').html(elm.html());
      }
    })
  });

  jQuery('.tsina-share-mindpin button.editable-submit').live('click',function(){
    var btn_elm = jQuery(this).closest('.btn')
    btn_elm.addClass('se');
    jQuery('.tsina-share-mindpin textarea').attr('disabled','disabled');
    var content = jQuery('.tsina-share-mindpin textarea').val();
    jQuery.ajax({
      url : '/connect_users/send_tsina_status_with_logo',
      type : 'POST',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var success_elm = btn_elm.find('.success');
        success_elm.show();
        setTimeout(function(){
          success_elm.fadeOut('slow');
        },600);
      },
      error : function(){
        var failure_elm = btn_elm.find('.failure');
        failure_elm.show();
        setTimeout(function(){
          failure_elm.fadeOut('slow');
        },600);
      },
      complete : function(res){
        btn_elm.removeClass('se');
        jQuery('.tsina-share-mindpin textarea').attr('disabled','');
      }
    })
  })
})


