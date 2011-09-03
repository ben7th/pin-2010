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

pie.show_page_overlay = function(){
  var overlay_elm = jQuery('<div class="page-overlay"></div>');
  overlay_elm
    .css('height',jQuery(document).height())
    .css('width',jQuery(document).width())
    .css('opacity',0.6)
    .hide().fadeIn(200)
    .appendTo(jQuery(document.body))
}

pie.hide_page_overlay = function(){
  jQuery('.page-overlay').fadeOut(200,function(){
    jQuery('.page-overlay').remove();
  })
}

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

//tag-aj-info
pie.load(function(){
  var overelm = null;
  var tag_info_elm = jQuery("<div class='tag-aj-info'>haha</div>");

  jQuery('.tag[rel=tag]').live('mouseenter',function(){
    overelm = jQuery(this);
    var elm = overelm;

    jQuery('.tag-aj-info').remove();

    setTimeout(function(){
//      pie.log(overelm);
      if(overelm == elm){
        var o = overelm.offset();
        var left = o.left;
        var top = o.top + overelm.height();
        tag_info_elm.css('left',left).css('top',top+2);
        tag_info_elm.html("<div class='box'></div>");
        tag_info_elm.addClass('aj-loading');

        jQuery('body').append(tag_info_elm);

        var tag_name = overelm.attr('data-name');
        jQuery.ajax({
          url : '/tags/'+tag_name+'/aj_info',
          type : 'GET',
          global: false,
          success : function(res){
            tag_info_elm.html(res);
            tag_info_elm.removeClass('aj-loading');
          }
        })
      }
    },500)

  }).live('mouseleave',function(){
    var elm = jQuery(this);
//    pie.log(overelm);
    setTimeout(function(){
      if(overelm == null || overelm.attr('data-name') == elm.attr('data-name')){
        overelm = null;
        jQuery('.tag-aj-info').remove();
      }
    },100)

  });

  jQuery('.tag-aj-info').live('mouseenter',function(){
    overelm = jQuery(this);
  }).live('mouseleave',function(){
    overelm = null;
    jQuery('.tag-aj-info').remove();
  })
})