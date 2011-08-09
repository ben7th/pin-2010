pie.load(function(){
  var op_elm = jQuery('.page-new-channel-op');
  if(!op_elm[0]) return;

  var btn_elm = jQuery('.page-new-channel-op .btn');
  var form_elm = jQuery('.page-new-channel-op .form');
  var data_form_elm = jQuery('.page-new-channel-op form');
  var form_ct_elm = jQuery('.page-new-channel-op .form .ct');
  var form_submit_elm = jQuery('.page-new-channel-op .form .create-submit');
  var form_cancel_elm = jQuery('.page-new-channel-op .form .create-cancel');
  var channels_elm = jQuery('.page-channels-set');


  btn_elm.live('click',function(){
    var width = btn_elm.outerWidth();
    var height = btn_elm.outerHeight();

    form_elm.css('width',width).css('height',height).css('opacity',0)
      .show()
      .delay(10)
      .animate({
        'width':300,'height':form_ct_elm.outerHeight(),'opacity':1
      },200,function(){
        form_elm.css('height','')
      })
    form_ct_elm.fadeIn(200);
  })

  var hide_op_form = function(){
    if(form_elm.is(':visible')){
      form_elm
        .animate({
          'width':btn_elm.outerWidth(),'height':btn_elm.outerHeight(),'opacity':0
        },200,function(){
          form_elm.hide();
        })
      form_ct_elm.fadeOut(200);
    }
  }

  jQuery(document).bind('click.page-new-channel-op',function(evt){
    var target = evt.target;
    var op_dom = op_elm[0];

    if(op_dom == target || jQuery.contains(op_dom,target)){
      return;
    }
    if(!jQuery.contains(document.body,target)){
      return;
    }

    hide_op_form();
  })

  form_cancel_elm.live('click',function(){
    hide_op_form();
  })

  form_submit_elm.live('click',function(){
    var param = data_form_elm.serialize();

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

    if(can_submit){
      //校验通过，可以创建
      //post /channels
      //params[:name]

      var loading_elm = jQuery('<div class="aj-loading"></div>')
      jQuery.ajax({
        url : '/channels',
        type : 'post',
        data : param,
        beforeSend : function(){
          hide_op_form();
          channels_elm.prepend(loading_elm)
        },
        success : function(res){
          loading_elm.remove();
          var new_elm = jQuery(res);
          channels_elm.prepend(new_elm.hide().fadeIn());
        },
        error : function(){
          loading_elm.addClass('error').delay(500).fadeOut();
        }
      })
    }
  })
})