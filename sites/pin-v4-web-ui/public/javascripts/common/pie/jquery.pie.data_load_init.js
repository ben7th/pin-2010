(function($){
  $(document).ready(function(){
    $('[data-load-url]').each(function(){
      var elm = jQuery(this);
      var url = elm.attr('data-load-url');
      elm.addClass('aj-loading');
      jQuery.ajax({
        type    : 'GET',
        url     : url,
        success : function(res){
          elm.html(res);
          elm.removeClass('aj-loading');
        }
      })
    });
  });
})(jQuery);

pie.load(function(){
  if(pie.env == 'development'){
    var elm = jQuery('<div class="rc5">development</div>');
    elm
      .css('width',210)
      .css('height',40)
      .css('font-size',36)
      .css('line-height','40px')
      .css('opacity','0.618')
      .css('position','absolute')
      .css('padding',10)
      .css('left',10)
      .css('top',20)
      .css('color','white')
      .css('background','black');
    jQuery('body').append(elm);
  }
})

pie.show_loading_bar = function(){
  var elm = jQuery('<div class="ajax-loading-bar"><div class="icon"></div>正在加载…</div>');
  jQuery('body').append(elm);
  return elm;
}

pie.hide_loading_bar = function(){
  jQuery('.ajax-loading-bar').remove();
}

jQuery('body')
  .bind("ajaxStart", function(){
    pie.show_loading_bar();
  })
  .bind("ajaxComplete", function(){
    pie.hide_loading_bar();
  });

pie.load(function(){
  jQuery('.flash-error, .flash-notice, .flash-success').each(function(){
    var elm = jQuery(this);
    elm.fadeOut('fast').fadeIn('fast');
  })
})

//去掉IE6 7的虚线框
pie.load(function(){
  if(jQuery.browser.msie){
    var v = jQuery.browser.version;
    if(v=='7.0' || v=='6.0'){
      jQuery('a').attr('hideFocus','hidefocus');
    }
  }
})

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

    dialog_elm.hide().fadeIn();

    jQuery('.jq-confirm-dialog .editable-submit').unbind();
    jQuery('.jq-confirm-dialog .editable-submit').bind('click',function(){
      jQuery('.jq-confirm-dialog').remove();
      func();
    });
  }

  jQuery('.jq-confirm-dialog .editable-cancel').live('click',function(){
    jQuery('.jq-confirm-dialog').remove();
  })
});
