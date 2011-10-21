pie.load(function(){
  var op_elm = jQuery('.page-new-collection-op');
  if(!op_elm[0]) return; //页面无对应元素则不加载事件
  
  var btn_elm = op_elm.find('.create');
  var pop_box_elm = op_elm.find('.pop-box');
  var data_form_elm = op_elm.find('form');
  var form_placeholder_elm = pop_box_elm.find('.form-placeholder');
  var form_submit_elm = op_elm.find('a.create-submit');
  var form_cancel_elm = op_elm.find('a.create-cancel');
  var form_title_ipter_elm = op_elm.find('input.ipt-title');

  var collections_grid_elm = jQuery('.page-ogrid.collections');
  var list_blank_elm = collections_grid_elm.find('.list-blank');


  //点击按钮弹出表单
  btn_elm.live('click',function(){
    var btn_width = btn_elm.outerWidth();
    var btn_height = btn_elm.outerHeight();

    pie.show_page_overlay();
    form_title_ipter_elm.val('');
    pop_box_elm.css('width',btn_width).css('height',btn_height).css('opacity',0)
      .show()
      .delay(10)
      .animate({
        'width':300,'height':form_placeholder_elm.outerHeight(),'opacity':1
      },200,function(){
        pop_box_elm.css('height','')
      })
      //必须中途去取placeholder的高度，否则取不到

    form_placeholder_elm.fadeIn(200);
  })

  //隐藏表单的函数
  var hide_op_form = function(){
    if(pop_box_elm.is(':visible')){
      pie.hide_page_overlay();
      pop_box_elm
        .animate({
          'width':btn_elm.outerWidth(),'height':btn_elm.outerHeight(),'opacity':0
        },200,function(){
          pop_box_elm.hide();
        })
      form_placeholder_elm.fadeOut(200);
    }
  }

  //点击界面任何位置，关闭表单
  jQuery(document).bind('click.page-new-collection-op',function(evt){
    var target = evt.target;
    var op_dom = op_elm[0];

    if(op_dom == target || jQuery.contains(op_dom,target)){return;}
    if(!jQuery.contains(document.body,target)){return;}
    
    hide_op_form();
  })

  //点击取消按钮，关闭表单
  form_cancel_elm.live('click',function(){
    hide_op_form();
  })

  //点击确定按钮，提交表单
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

      //var loading_elm = jQuery('<div class="aj-loading"></div>')
      jQuery.ajax({
        url : '/collections',
        type : 'post',
        data : param,
        beforeSend : function(){
          hide_op_form();
          //collections_grid_elm.prepend(loading_elm)
        },
        success : function(res){
          list_blank_elm.remove();
          var new_elm = jQuery(res);
          collections_grid_elm.prepend(new_elm.hide().fadeIn());
        },
        error : function(){
          //loading_elm.addClass('error').delay(500).fadeOut();
        }
      })
    }
  })
})


