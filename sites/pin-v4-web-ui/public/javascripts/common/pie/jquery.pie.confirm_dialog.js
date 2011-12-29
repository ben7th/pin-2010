//confirm对话框，取代系统默认
pie.load(function(){
  jQuery.fn.confirm_dialog = function(str,func){
    var elm = jQuery(this);
    var off = elm.offset();

    func == func || function(){};

    var dialog_elm = jQuery(
      '<div class="jq-confirm-dialog popdiv">'+
        '<div class="d">'+
          '<div class="data"><div class="icon">?</div>'+str+'</div>'+
          '<div class="btns">'+
            '<a class="button editable-submit" href="javascript:;">确定</a>'+
            '<a class="button editable-cancel" href="javascript:;">取消</a>'+
          '</div>'+
        '</div>'+
      '</div>'
    );

    jQuery('.jq-confirm-dialog').remove();
    dialog_elm.css('left',off.left - 100 + elm.outerWidth()/2).css('top',off.top - 83);
    jQuery('body').append(dialog_elm);

    dialog_elm.hide().fadeIn(200);
    pie.show_page_overlay();

    jQuery('.jq-confirm-dialog .editable-submit').unbind();
    jQuery('.jq-confirm-dialog .editable-submit').bind('click',function(){
      jQuery('.jq-confirm-dialog').remove();
      pie.hide_page_overlay();
      func();
    });
  }

  jQuery('.jq-confirm-dialog .editable-cancel').live('click',function(){
    jQuery('.jq-confirm-dialog').remove();
    pie.hide_page_overlay();
  })
});