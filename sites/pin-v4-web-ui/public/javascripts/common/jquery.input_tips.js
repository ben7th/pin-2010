// 给jQuery对象增加 input 的方法，绑定输入事件
jQuery.fn.input = function(fn) {
  var $this = this;
  return fn
  ?
  $this.bind({
    'input.input': function(event) {
      $this.unbind('keydown.input');
      fn.call(this, event);
    },
    'keydown.input': function(event) {
      fn.call(this, event);
    }
  })
  :
  $this.trigger('keydown.input');
};

pie.load(function(){
  jQuery.fn.pie_j_tips = function() {
    try{
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
    }catch(e){
      pie.log(e)
    }
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