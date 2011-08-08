pie.load(function(){
  var op_elm = jQuery('.page-new-collection-op');
  if(!op_elm[0]) return;
  
  var btn_elm = jQuery('.page-new-collection-op .btn');
  var form_elm = jQuery('.page-new-collection-op .form');
  var data_form_elm = jQuery('.page-new-collection-op form');
  var form_ct_elm = jQuery('.page-new-collection-op .form .ct');
  var form_submit_elm = jQuery('.page-new-collection-op .form .create-submit');
  var form_cancel_elm = jQuery('.page-new-collection-op .form .create-cancel');
  var collections_elm = jQuery('.page-collections');


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

  jQuery(document).bind('click.page-new-collection-op',function(evt){
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

    //发送范围
    var sendto_elm = data_form_elm.find('.sendto-hid');
    if(jQuery.string(sendto_elm.val()).blank()){
      can_submit = false;
      pie.inputflash(data_form_elm.find('.sendto-ipter'));
    }

    if(can_submit){
      //校验通过，可以创建
      //post /collections
      //params[:title],params[:description],params[:sendto]

      var loading_elm = jQuery('<div class="aj-loading"></div>')
      jQuery.ajax({
        url : '/collections',
        type : 'post',
        data : param,
        beforeSend : function(){
          hide_op_form();
          collections_elm.prepend(loading_elm)
        },
        success : function(res){
          loading_elm.remove();
          var new_elm = jQuery(res).find('.collection');
          collections_elm.prepend(new_elm.hide().fadeIn());
        },
        error : function(){
          loading_elm.addClass('error').delay(500).fadeOut();
        }
      })
    }
  })
})


