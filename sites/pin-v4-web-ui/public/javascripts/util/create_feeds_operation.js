pie.load(function(){
  var data_form_elm = jQuery('.page-new-feed-form');

  if(data_form_elm.length == 0) return;
  
  var rich_editor = new baidu.editor.ui.Editor({
    minFrameHeight: 300,
    autoHeightEnabled: false,
    /**/
    ui: {
      toolbars: [
        [
          'Bold', 'Underline','StrikeThrough',
          'InsertOrderedList',"BlockQuote"
        ]
      ]
    }
  });
  rich_editor.render("page-feed-detail-ipter");

  jQuery('#edui1_bottombar').hide();

  jQuery(document).delegate('.page-new-feed-form .create-submit','click',function(){
    var elm = jQuery(this);
    var data_form_elm = elm.closest('form');

    //富文本编辑器给textarea赋值
    data_form_elm.find('.detail-ipter').val(rich_editor.getContent());

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

pie.load(function(){
  if(jQuery('.cell.layout-auto').length > 0){
    var document_resize = function(){
      var height = jQuery(window).height() - 131;
      jQuery('.cell').css('height',height);
      jQuery('.layout-main').css('height',height);
    }

    document_resize();
    jQuery(window).resize(document_resize);
  }
})