pie.load(function(){
  jQuery.fn.pie_j_tips = function() {
    var elm = jQuery(this);
    var jt_label_elm = elm.closest('.field').find('label');
    jt_label_elm.mousedown(function(){
      setTimeout(function(){
        elm.focus();
      },1);
    })

    //初始化
    j_tip_active(elm);

    //focus和blur的事件绑定，不能以live来声明
    elm
    .change(function(){
      j_tip_active(elm)
    })
    .input(function(){
      j_tip_active(elm)
    })
  };

  function j_tip_active(elm){
    var jt_label_elm = elm.closest('.field').find('label');
    var value = elm.val();

    if(jQuery.string(value).blank()){
      jt_label_elm.show();
    }else{
      jt_label_elm.hide();
    }
  }

  jQuery('.j-tip').each(function(){
    jQuery(this).pie_j_tips();
  })
})