//创建主题页面

pie.load(function(){
  var data_form_elm = jQuery('.page-new-feed-form');
  if(data_form_elm.length == 0) return;

  var data_form_side_elm = jQuery('.page-new-feed-form-side');

  //根据传入的jq对象和flag值，勾选或不勾选collection
  function check_channel(elm, flag){
    var cb_elm = elm.find('input[type=checkbox]');
    if(flag){
      elm.addClass('checked');
      cb_elm.attr('checked', true);
    }else{
      elm.removeClass('checked');
      cb_elm.attr('checked', false);
    }
  }

  //表单初始化
  var loaded_draft = data_form_elm.find('.loaded_draft_mark').length > 0;
  var aimed_collection = data_form_elm.find('.aimed_collection_mark').length > 0;

  //如果当前没有加载草稿，则把所有表单域清空
  //刷新创建页时，表单域应该是清空的。需要防止浏览器的表单缓存。
  if(!loaded_draft){
    data_form_elm.find('.title-ipter').val('');
    data_form_elm.find('.photos-ipter').val('');
    data_form_elm.find('.detail-ipter').val('');
    data_form_elm.find('.collections-ipter').val('');
    if(aimed_collection){
      data_form_elm.find('.collections-ipter').val(data_form_elm.find('.aimed_collection_mark').domdata('id'));
    }
    data_form_elm.find('.send-tsina-ipter').val('');
  }

  //加载collection勾选列表
  var selected_collection_ids = data_form_elm.find('.collections-ipter').val().split(',');

  //全部不勾选
  data_form_side_elm.find('.field.collections .c').each(function(){
    var elm = jQuery(this);
    check_channel(elm, false);
  })

  //勾选在列表中的
  selected_collection_ids.each(function(id){
    var elm = data_form_side_elm.find('.field.collections .c[data-id='+id+']')
    check_channel(elm, true);
  });

  //collection选择
  data_form_side_elm.find('.field.collections .c').bind('click',function(){
    var elm = jQuery(this);

    if(elm.hasClass('checked')){
      check_channel(elm, false);
    }else{
      check_channel(elm, true);
    }

    ids = [];
    data_form_side_elm.find('.field.collections .c.checked').each(function(){
      ids.push(jQuery(this).domdata('id'));
    });

    data_form_elm.find('.collections-ipter').val(ids.join(','))
  });

  //发送到微博的选项勾选后提取参数
  data_form_side_elm.find('.field.send-to-tsina .c').bind('click',function(){
    var elm = jQuery(this);

    if(elm.hasClass('checked')){
      check_channel(elm, false);
      data_form_elm.find('.send-tsina-ipter').val('');
    }else{
      check_channel(elm, true);
      data_form_elm.find('.send-tsina-ipter').val(true);
    }
  });

  // ----------------

  //表单提交，提交之前进行参数检查
  data_form_elm.find('.create-submit').bind('click',function(){
    //参数检查
    var can_submit = true;
    var errors = [];

    //表单不可以是空的，标题，图片，正文，必须至少有一项
    //至少一项 凡是有classname包含 .at-least 的项目，至少要填一项
    var flag = false
    data_form_elm.find('.field .at-least').each(function(){
      var field_elm = jQuery(this);
      flag = flag || !jQuery.string(field_elm.val()).blank();
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

  //点击保存草稿按钮
  data_form_elm.find('.create-save-draft').bind('click',function(){
    var data = data_form_elm.serialize();

    //POST /post_drafts

    jQuery.ajax({
      url : '/post_drafts',
      type : 'POST',
      data : data,
      success : function(){

      }
    })
  })

});