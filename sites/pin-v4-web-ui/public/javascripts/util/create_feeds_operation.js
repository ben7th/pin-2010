pie.load(function(){
  jQuery(document).delegate('.page-new-feed-form .create-submit','click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('form');
    if(form_elm.find('.sendto-hid').val() == ''){
      alert('请选择发送范围');
      return;
    }
    form_elm.submit();
  })
})