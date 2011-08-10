pie.load(function(){
  var data_form_elm = jQuery('.page-new-feed-form');

  jQuery(document).delegate('.page-new-feed-form .create-submit','click',function(){
    var elm = jQuery(this);
    var data_form_elm = elm.closest('form');

    //参数检查
    var can_submit = true;

    //必填字段
    data_form_elm.find('.field .need').each(function(){
      var elm = jQuery(this);
      if(jQuery.string(elm.val()).blank()){
        can_submit = false;
        pie.inputflash(elm);
      }
    });

    //发送范围
    var sendto_elm = data_form_elm.find('.sendto-hid');
    if(jQuery.string(sendto_elm.val()).blank()){
      can_submit = false;
      pie.inputflash(data_form_elm.find('.sendto-ipter'));
    }

    if(can_submit){
      data_form_elm.submit();
    }
  })
})