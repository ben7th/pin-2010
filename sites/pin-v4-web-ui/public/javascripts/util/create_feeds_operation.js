//创建主题页面

pie.load(function(){
  var data_form_elm = jQuery('.page-new-feed-form');

  if(data_form_elm.length == 0) return;

  //collection选择
  jQuery(document).delegate('.page-new-feed-form .form-collection-select .field.collections .c','click',function(){
    var elm = jQuery(this);
    var cb_elm = elm.find('input[type=checkbox]');

    if(elm.hasClass('checked')){
      cb_elm.attr('checked',false);
      elm.removeClass('checked');
    }else{
      cb_elm.attr('checked',true);
      elm.addClass('checked');
    }

    ids = [];
    jQuery('.page-new-feed-form .form-collection-select .field.collections .c.checked').each(function(){
      ids.push(jQuery(this).domdata('id'));
    });

    jQuery('.page-new-feed-form .collections-ipter').val(ids.join(','))
  });

  //表单提交，提交之前进行参数检查
  jQuery(document).delegate('.page-new-feed-form .create-submit','click',function(){
    var elm = jQuery(this);
    var data_form_elm = elm.closest('form');

    //参数检查
    var can_submit = true;

//    //必填字段 凡是有classname包含need的都是必填
//    data_form_elm.find('.field .need').each(function(){
//      var elm = jQuery(this);
//      if(jQuery.string(elm.val()).blank()){
//        can_submit = false;
//        pie.inputflash(elm);
//      }
//    });

//    //发送范围
//    var sendto_elm = data_form_elm.find('.sendto-hid');
//    if(jQuery.string(sendto_elm.val()).blank()){
//      can_submit = false;
//      pie.inputflash(data_form_elm.find('.sendto-ipter'));
//    }

    if(can_submit){
      data_form_elm.submit();
    }
  })
})

//自适应高度
//pie.load(function(){
//  if(jQuery('.cell.layout-auto').length > 0){
//    var document_resize = function(){
//      var height = jQuery(window).height() - 131;
//      jQuery('.cell').css('height',height);
//      jQuery('.layout-main').css('height',height);
//    }
//
//    document_resize();
//    jQuery(window).resize(document_resize);
//  }
//})