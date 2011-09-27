//创建主题页面

pie.load(function(){
  var data_form_elm = jQuery('.page-new-feed-form');
  if(data_form_elm.length == 0) return;


  //collection选择
  jQuery(document).delegate('.page-new-feed-form-side .form-collection-select .field.collections .c','click',function(){
    var elm = jQuery(this);
    var cb_elm = elm.find('input[type=checkbox]');

    if(elm.hasClass('checked')){
      cb_elm.attr('checked',false); elm.removeClass('checked');
    }else{
      cb_elm.attr('checked', true); elm.addClass('checked');
    }

    ids = [];
    jQuery('.page-new-feed-form-side .form-collection-select .field.collections .c.checked').each(function(){
      ids.push(jQuery(this).domdata('id'));
    });

    data_form_elm.find('.collections-ipter').val(ids.join(','))
  });

  //发送到微博
  jQuery(document).delegate('.page-new-feed-form-side .field.send-to-tsina .c','click',function(){
    var elm = jQuery(this);
    var cb_elm = elm.find('input[type=checkbox]');

    if(elm.hasClass('checked')){
      cb_elm.attr('checked',false); elm.removeClass('checked');
      data_form_elm.find('.send-tsina-ipter').val('');
    }else{
      cb_elm.attr('checked', true); elm.addClass('checked');
      data_form_elm.find('.send-tsina-ipter').val(true);
    }
  });

  //表单提交，提交之前进行参数检查
  jQuery(document).delegate('.page-new-feed-form .create-submit','click',function(){
    var elm = jQuery(this);
    var data_form_elm = elm.closest('form');

    //参数检查
    var can_submit = true;
    var errors = [];

    //表单不可以是空的，标题，图片，正文，必须至少有一项
    //至少一项 凡是有classname包含 .at-least 的项目，至少要填一项
    var flag = false
    data_form_elm.find('.field .at-least').each(function(){
      var elm = jQuery(this);
      flag = flag || !jQuery.string(elm.val()).blank();
    });
    if(flag == false){
      can_submit = false;
      errors.push('不要创建空主题');
    }

    //必须选择收集册
    var collection_ids_ipt_elm = data_form_elm.find('.collections-ipter');
    if(jQuery.string(collection_ids_ipt_elm.val()).blank()){
      can_submit = false;
      errors.push('请选择发送范围');
    }

    if(can_submit){
      data_form_elm.submit();
    }else{
      data_form_elm.find('.submit-info')
        .stop().css('opacity',1).html(errors.join('；'))
        .show().fadeOut(10000);
    }
  });

  //保存草稿
});